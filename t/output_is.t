use Test::More tests => 6;
use Test::Output;
use Test::Builder::Tester;

use strict;
use warnings;

test_out('ok 1 - Testing STDOUT');
output_is(sub {print "TEST OUT\n"},"TEST OUT\n",'','Testing STDOUT');
test_test('output_is handles STDOUT');

test_out('ok 1 - Testing STDERR');
output_is(sub {print STDERR "TEST OUT\n"},'',"TEST OUT\n",'Testing STDERR');
test_test('output_is handles STDERR');

test_out('ok 1 - Testing STDOUT & STDERR');
output_is(
          sub {
            print "TEST OUT\n"; 
            print STDERR "TEST ERR\n";
          },"TEST OUT\n","TEST ERR\n",'Testing STDOUT & STDERR'
        );
test_test('output_is handles STDOUT & STDERR');

test_out('ok 1 - Testing STDOUT printf');
output_is(sub {printf("TEST OUT - %d\n",25)},"TEST OUT - 25\n",'','Testing STDOUT printf');
test_test('output_is handles STDOUT printf');

test_out('not ok 1 - Testing STDOUT failure');
test_err("\n#     Failed test ($0 at line ".line_num(+2).")");
test_diag("STDOUT is:\n# TEST OUT\n# not:\n# TEST OUT STDOUT\n# as expected\n# STDERR is:\n# \n# not:\n# \n# as expected");
output_is(sub {print "TEST OUT"},"TEST OUT STDOUT",'','Testing STDOUT failure');
test_test('output_is handles STDOUT not found');

test_out('not ok 1 - Testing STDERR failure');
test_err("\n#     Failed test ($0 at line ".line_num(+2).")");
test_diag("STDOUT is:\n# \n# not:\n# \n# as expected\n# STDERR is:\n# TEST OUT\n# not:\n# TEST OUT STDERR\n# as expected");
output_is(sub {print STDERR "TEST OUT"},'',"TEST OUT STDERR",'Testing STDERR failure');
test_test('output_is handles STDERR not found');
