use Test::More tests => 17;
use Test::Tester;
use Test::Output;

use strict;
use warnings;

check_test( sub {
            stderr_like(sub {
                        print STDERR "TEST OUT\n";
                      },
                      qr/OUT/i,
                      'Testing STDERR'
                    )
            },{
              ok => 1,
              name => 'Testing STDERR',
            },'STDERR matching success'
          );

check_test( sub {
            stderr_like(sub {
                        print STDERR "TEST OUT\n";
                      },
                      'OUT',
                      'Testing STDERR'
                    )
            },{
              ok => 0,
              name => 'stderr_like',
              diag => "'OUT' doesn't look much like a regex to me.\n",
            },'STDERR matching success'
          );

check_test( sub {
            stderr_like(sub {
                        print STDERR "TEST OUT\n";
                      },
                      qr/out/,
                      'Testing STDERR'
                    )
            },{
              ok => 0,
              name => 'Testing STDERR',
              diag => "STDERR:\nTEST OUT\n\ndoesn't match:\n(?-xism:out)\nas expected\n",
            },'STDERR not matching failure'
          );

