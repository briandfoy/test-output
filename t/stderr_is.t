use Test::More tests => 2;
use Test::Output;
use Test::Builder::Tester;
use Test::Builder::Tester::Color;

use strict;
use warnings;

test_out('ok 1 - Testing STDERR');
stderr_is(sub {print STDERR "TEST OUT\n"},"TEST OUT\n",'Testing STDERR');
test_test('output_is handles STDERR');

test_out('not ok 1 - Testing STDERR failure');
test_err("\n#     Failed test ($0 at line ".line_num(+2).")");
test_diag("STDERR is:\n# TEST OUT\n# not:\n# TEST OUT STDERR\n# as expected");
stderr_is(sub {print STDERR "TEST OUT"},"TEST OUT STDERR",'Testing STDERR failure');
test_test('output_is handles STDERR not found');
