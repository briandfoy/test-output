package Test::Output;

use warnings;
use strict;

use Test::Builder;
use Test::Output::Tie;
require Exporter;
use Filehandle;

our @ISA=qw(Exporter);
our @EXPORT=qw(output_is stderr_is stdout_is);

my $Test = Test::Builder->new;

=head1 NAME

Test::Output - Utilities to test STDOUT and STDERR messages.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Test::More tests => 4;
    use Test::Output;

    sub writer {
      print "Write out.\n";
      print STDERR "Error out.\n";
    }
    
    output_is(\&writer,"Write out.\n",'Test STDOUT');
    output_is(\&writer,"Error out.\n",'Test STDERR');

    stdout_is(\&writer,"Write out.\n",'Test STDOUT');

    stderr_is(sub { print "This is STDOUT\n"; writer(); },
              "Error out.\n",'Test STDERR');

=head1 DESCRIPTION

Test::Output provides functions to test date sent to both STDOUT 
and STDERR.

Test::Output ties STDOUT and STDERR using Test::Output::Tie. 

All functions are exported.

=head2 output_is

   output_is( $coderef, $expected, 'comment' );

output_is() compares $expected to the output produced by $coderef, 
and fails if they do not match.

=cut

sub output_is {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my($stdout,$stderr)=_errandout($test);

  my $ok=($stdout eq $expected) || ($stderr eq $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT is:\n$stdout\nnot:\n$expected\nas expected\n",
               "STDERR is:\n$stderr\nnot:\n$expected\nas expected" ) unless($ok);

  return $ok;
}

=head2 stdout_is

   stderr_is( $coderef, $expected, 'comment' );

stdout_is() is similar to output_is() except that it only compares 
$expected to STDOUT captured from $codref.

=cut

sub stdout_is {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stdout=_out($test);

  my $ok=($stdout eq $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT is:\n$stdout\nnot:\n$expected\nas expected" ) unless($ok);

  return $ok;
}

=head2 stderr_is

   stderr_is( $coderef, $expected, 'comment' );

stderr_is() is similar to output_is(), and stdout_is() except that it only
compares $expected to STDERR captured from $codref.

=cut

sub stderr_is {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stderr=_err($test);

  my $ok=($stderr eq $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDERR is:\n$stderr\nnot:\n$expected\nas expected" ) unless($ok);

  return $ok;
}

sub _errandout {
  my $test=shift;

  STDOUT->autoflush(1);
  STDERR->autoflush(1);
  my $out=tie *STDOUT, 'Test::Output::Tie';
  my $err=tie *STDERR, 'Test::Output::Tie';

  &$test;
  my $stdout=$out->read;
  my $stderr=$err->read;

  undef $out;
  undef $err;
  untie *STDOUT;
  untie *STDERR;

  return ($stdout,$stderr);
}


sub _err {
  my $test=shift;

  STDERR->autoflush(1);
  my $err=tie *STDERR, 'Test::Output::Tie';

  &$test;
  my $stderr=$err->read;

  undef $err;
  untie *STDERR;

  return $stderr;
}

sub _out {
  my $test=shift;

  STDOUT->autoflush(1);
  my $out=tie *STDOUT, 'Test::Output::Tie';

  &$test;
  my $stdout=$out->read;

  undef $out;
  untie *STDOUT;

  return $stdout;
}


=head1 AUTHOR

Shawn Sorichetti, C<< <ssoriche@coloredblocks.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-output@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Thanks to chromatic whose TieOut.pm was the basis for capturing output.

=head1 COPYRIGHT & LICENSE

Copyright 2005 Shawn Sorichetti, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Test::Output
