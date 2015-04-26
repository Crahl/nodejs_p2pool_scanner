#!/usr/bin/perl

use strict;
use warnings;
use RRDs;
use Data::Dumper;
use JSON;

my $json = JSON->new->allow_nonref;

my @opts;

push @opts, $ARGV[0];		#Filename
push @opts, $ARGV[1];		#Consolidation Function (AVERAGE, MIN, MAX, LAST)
push @opts, "-r $ARGV[2]";	#--resolution|-r resolution (default is the highest resolution)
push @opts, "-e $ARGV[3]";	#--end|-e end (default now)
push @opts, "-s $ARGV[4]";	#--start|-s start (default end-1day)

my ($start,$step,$names,$data) = RRDs::fetch @opts;

my %output;
my @datasources = @$names;	#Dereference DS Names
@output{@datasources} = undef;

for my $t (0 .. $#{$data}-1) {
	for my $i (0 .. @datasources-1) {
		push @{$output{$datasources[$i]}}, $data->[$t][$i];
	}
}

#print Dumper %output;
print $json->pretty->encode(\%output);

