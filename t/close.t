#!perl

use Test::Tester;
use Test::More tests => 1;
use Test::Output;

use strict;
use warnings;

eval {
    stdout_is(
        sub { close STDOUT; },
        '',
        "The close doesn't cause expcetions"
    );
};
