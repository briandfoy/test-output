package Test::Output;

use warnings;
use strict;

use Test::Builder;
use Test::Output::Tie;
require Exporter;
use Filehandle;

our @ISA=qw(Exporter);
our @EXPORT=qw(output_is);

my $Test = Test::Builder->new;

=head1 NAME

Test::Output - The great new Test::Output!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.00_01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Test::Output;

    my $foo = Test::Output->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 output_is

=cut

sub output_is {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my($stdout,$stderr)=_errandout($test);

# STDOUT->autoflush(1);
# STDERR->autoflush(1);
# my $out=tie *STDOUT, 'Test::Output::Tie';
# my $err=tie *STDERR, 'Test::Output::Tie';

# &$test;
# my $stdout=$out->read;
# my $stderr=$err->read;

# undef $out;
# undef $err;
# untie *STDOUT;
# untie *STDERR;

  my $ok=($stdout eq $expected) || ($stderr eq $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT is:\n$stdout\nnot:\n$expected\nas expected\n",
               "STDERR is:\n$stderr\nnot:\n$expected\nas expected" ) unless($ok);
# my $var="BLAH BLAH";
# $Test->diag( "NO MATCH: $var" ) unless($ok);
# $Test->diag( 'NO MATCH: ' ) unless($ok);


# print "**STDOUT: $stdout**\n" unless($ok);
# print "STDERR: $stderr";
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


=head2 function2

=cut

sub function2 {
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

1; # End of Test::Output

