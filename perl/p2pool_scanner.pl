#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

use LWP::Simple;
use JSON;
#use JSON qw( decode_json );

use HTTP::Request::Common qw(GET);
use POE qw(Component::Client::HTTP);
#use Geo::IP::PurePerl;
use Geo::IP;

POE::Component::Client::HTTP->spawn(
	Alias => 	'ua',
	Timeout =>	2,
);

######################################
########USER DEFINED VARIABLES########
######################################
my $port = 7903;
my $coin = "DASH";
my $output_file = '../dash.json';
######################################
######################################

my @addresses;	#Array to load addresses into
my @output;	#Array to store results in

#my $gi = Geo::IP::PurePerl->new(GEOIP_STANDARD);
my $gi = Geo::IP->open("/usr/local/share/GeoIP/GeoLiteCity.dat", GEOIP_STANDARD);

######################################
##Get P2Pool addrs file (from http location here)
my $url = 'http://p2pool:8080/addrs';
my $json = get $url;
die "Couldn't get $url" unless defined $json;
######################################

my @addrs = decode_json($json);

foreach (@{$addrs[0]}){
        foreach my $node ($_){
                my @array = @$node;
                push (@addresses, $array[0][0]);
        }
}

#Save timestamp and coin details into output
my @line = (time, $port, $coin);
push @output, \@line;

######################################

POE::Session->create(package_states => [main => ["_start", "got_response"]]);
POE::Kernel->run();
######################################

#Prepare output and write to file
my $json_output = encode_json \@output;
open (FILE, '>', $output_file) or die "Could not open file '$output_file' $!";
print FILE $json_output;
close FILE;

exit;

######################################
######################################

sub get_another_url {
START:
	my $ip = shift @addresses;
	return unless defined $ip;
	if ($ip eq "0.0.0.0"){goto START;}
	my $next_url = "http://" . $ip . ":" . $port . "/fee";
	return $next_url;
}

sub _start {
	my $kernel = $_[KERNEL];

	for (1 .. 10) {
		my $next_url = get_another_url();
		last unless defined $next_url;
		$kernel->post("ua" => "request", "got_response", GET $next_url);
	}
}

sub got_response {
	my ($heap, $request_packet, $response_packet) = @_[HEAP, ARG0, ARG1];
	my $http_response = $response_packet->[0];
	my %http_r = %$http_response;

	my $host = $http_r{_request}{_headers}{host};		#Target host
	my @split = split(/:/, $host);				#Split port number from IP
	my $ip = $split[0];					#Target IP

	if ($http_r{_content} =~ m/^<html>/){
		print "$host = No Match\n";
	}else{
		if ($http_r{_content} =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/){
			my $record = $gi->record_by_addr($ip);

			my $country_code = lc($record->country_code);
			my $country_name = lc($record->country_name);
			my $latitude = $record->latitude;
			my $longitude = $record->longitude;

			my @line = ($ip, $country_name, $country_code, $latitude, $longitude);
			push @output, \@line;
			print "$ip $port $coin $country_name $country_code $latitude $longitude = $http_r{_content}\n";
		}else{
			print "$host = No Match\n";
		}
	}

	my $next_url = get_another_url();
	if (defined $next_url) {
		$_[KERNEL]->post("ua" => "request", "got_response", GET $next_url);
	}
}


