#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use Test::Output::Tie;

my $out=tie *STDOUT, 'Test::Output::Tie';

print "Output Test";

my $output=$out->read;

undef $out;
untie *STDOUT;

print "OUTPUT: $output\n";
