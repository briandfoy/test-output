use Test::More tests => 16;
use lib 't/lib';
use Test::Tester;
use Test::Output;

use strict;
use warnings;

check_test( sub {
            stdout_is(sub {
                        print "TEST OUT\n";
                      },
                      "TEST OUT\n",
                      'Testing STDOUT'
                    )
            },{
              ok => 1,
              name => 'Testing STDOUT',
            }
          );

check_test( sub {
            stdout_is(sub {
                        printf("TEST OUT - %d\n",42);
                      },
                      "TEST OUT - 42\n",
                      'Testing STDOUT printf'
                    )
            },{
              ok => 1,
              name => 'Testing STDOUT printf',
            }
          );

check_test( sub {
            stdout_is(sub {
                        print "TEST OUT";
                      },
                      "TEST OUT STDOUT",
                      'Testing STDOUT failure'
                    )
            }, {
              ok => 0,
              name => 'Testing STDOUT failure',
              diag => "STDOUT is:\nTEST OUT\nnot:\nTEST OUT STDOUT\nas expected\n",
            }
          );
