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

    use Test::More tests => 3;
    use Test::Output;

    sub writer {
      print "Write out.\n";
      print STDERR "Error out.\n";
    }
    
    output_is(\&writer,"Write out.\n",'Test STDOUT');
    output_is(\&writer,"Error out.\n",'Test STDERR');

    stderr_is(\&writer,"Error out.\n",'Test STDERR');

    stdout_is(\&writer,"Write out.\n",'Test STDOUT');

=head1 DESCRIPTION



=head1 FUNCTIONS

=head2 output_is

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

=head2 stderr_is

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

=head2 stdout_is

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

=head1 AUTHOR

Shawn Sorichetti, C<< <ssoriche@coloredblocks.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-output@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Shawn Sorichetti, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

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

1; # End of Test::Output

