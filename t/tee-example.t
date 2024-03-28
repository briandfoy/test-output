#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use v5.10;

use Test::Output qw/ combined_like /;

sub multiply {
    my ($input) = @_;
    say "Calculating $input * 2";
    return $input * 2;
}

combined_like { multiply(23) } qr/Calculating 23 \* 2/, 'multiply works';

done_testing;
