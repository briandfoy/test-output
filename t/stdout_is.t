use Test::More tests => 3;
use Test::Output;
use Test::Builder::Tester;
use Test::Builder::Tester::Color;

use strict;
use warnings;

test_out('ok 1 - Testing STDOUT');
stdout_is(sub {print "TEST OUT\n"},"TEST OUT\n",'Testing STDOUT');
test_test('output_is handles STDOUT');

test_out('ok 1 - Testing STDOUT printf');
stdout_is(sub {printf("TEST OUT - %d\n",42)},"TEST OUT - 42\n",'Testing STDOUT printf');
test_test('output_is handles STDOUT printf');

test_out('not ok 1 - Testing STDOUT failure');
test_err("\n#     Failed test ($0 at line ".line_num(+2).")");
test_diag("STDOUT is:\n# TEST OUT\n# not:\n# TEST OUT STDOUT\n# as expected");
stdout_is(sub {print "TEST OUT"},"TEST OUT STDOUT",'Testing STDOUT failure');
test_test('output_is handles STDOUT not found');
