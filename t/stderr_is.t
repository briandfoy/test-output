use Test::More tests => 12;
use Test::Tester;
use Test::Output;

use strict;
use warnings;

check_test( sub {
            stderr_is(sub {
                        print STDERR "TEST OUT\n";
                      },
                      "TEST OUT\n",
                      'Testing STDERR'
                    )
            },{
              ok => 1,
              name => 'Testing STDERR',
              diag => '',
            },'STDERR matching success'
          );

check_test( sub {
            stderr_is(sub {
                        print STDERR "TEST OUT\n";
                      },
                      "TEST OUT STDERR\n",
                      'Testing STDERR'
                    )
            },{
              ok => 0,
              name => 'Testing STDERR',
              diag => "STDERR is:\nTEST OUT\n\nnot:\nTEST OUT STDERR\n\nas expected\n",
            },'STDERR not matching failure'
          );

