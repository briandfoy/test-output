#!/usr/bin/perl
use lib qw(lib);
use v5.10;

use Test::More tests => 1;
use Test::Output;
say Test::Output->VERSION;
my $out = combined_like { say "hello"; } qr/h/;
like $out, qr{hello};
__END__
1..1
1.032
ok 1


__END__
good f7f524a7ef98f6c589eead203b304cc3f8aaa591
bad 934f2cdfea99239c55de804e1c62fedb36b37a27
