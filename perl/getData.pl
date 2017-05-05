#!/usr/bin/perl -w

use strict;
use warnings;
use LWP::Simple;
use LWP::UserAgent;
use JSON qw( decode_json );
use RRDs;
use File::Path;
use Data::Dumper;

my $rrdPath = "rrd";
my $rrdFile = "dash.rrd";

if (!-d $rrdPath){
	print "$rrdPath does not exist\n";
	mkpath("$rrdPath", 0, 0755);
}

if (!-e $rrdPath. "/" . $rrdFile){
	print "Creating RRD file " . $rrdFile . "\n";

	RRDs::create($rrdPath . "/" . $rrdFile,
	"-s 60",
	"DS:dash_hashrate:GAUGE:120:0:U",
	"DS:p2pool_hashrate:GAUGE:120:0:U",
	"DS:dash_diff:GAUGE:120:0:U",
	"RRA:AVERAGE:0.5:1:1440",		#01day - 060s avg
	"RRA:AVERAGE:0.5:300:144",		#30day - 300s avg
	"RRA:MIN:0.5:1:1440",			#01day - 060s avg
	"RRA:MIN:0.5:300:144",			#30day - 300s avg
	"RRA:MAX:0.5:1:1440",			#01day - 060s avg
	"RRA:MAX:0.5:300:144"			#30day - 300s avg
	);
}
#############################################################################################
###Get P2Pool Stats
#############################################################################################

my $url = 'http://p2pool:7903/global_stats';
my $json = get $url;
die "Couldn't get $url" unless defined $json;

my $decoded_json = decode_json($json);

#print Dumper $decoded_json;

print "Network Hashrate: $decoded_json->{'network_hashrate'}\n";
print "Pool Hashrate: $decoded_json->{'pool_hash_rate'}\n";
print "Network Difficulty: $decoded_json->{'network_block_difficulty'}\n";

#############################################################################################
###Update RRD File
#############################################################################################
RRDs::update ($rrdPath . "/" . $rrdFile,"N:$decoded_json->{'network_hashrate'}:$decoded_json->{'pool_hash_rate'}:$decoded_json->{'network_block_difficulty'}");




