package Test::Output;

use warnings;
use strict;

use Test::Builder;
use Test::Output::Tie;
require Exporter;

our @ISA=qw(Exporter);
our @EXPORT=qw(output_from output_is output_isnt 
               stderr_from stderr_is stderr_isnt stderr_like stderr_unlike
               stdout_from stdout_is stdout_isnt stdout_like stdout_unlike
             );

my $Test = Test::Builder->new;

=head1 NAME

Test::Output - Utilities to test STDOUT and STDERR messages.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

    use Test::More tests => 4;
    use Test::Output;

    sub writer {
      print "Write out.\n";
      print STDERR "Error out.\n";
    }

    stdout_is(\&writer,"Write out.\n",'Test STDOUT');

    stderr_isnt(\&writer,"No error out.\n",'Test STDERR');
    
    output_is(
              \&writer,
              "Write out.\n",
              "Error out.\n",
              'Test STDOUT & STDERR'
            );

=head1 DESCRIPTION

Test::Output provides a simple interface for testing output send to STDOUT
or STDERR. A number of different utilies are included to try and be as
flexible as possible to the tester.
         
While Test::Output requires Test::Tester during installation, this
requirement is only for it's own tests, not for what it's testing. One of
the main ideas behind Test::Output is to make it as self contained as
possible so it can be included with other's modules. As of this release
the only requirement is to include Test::Output::Tie along with it.

Test::Output ties STDOUT and STDERR using Test::Output::Tie. 

All functions are exported.

=cut

=head2 stdout_is stdout_isnt

   stdout_is  ( $coderef, $expected, 'comment' );
   stdout_isnt( $coderef, $expected, 'comment' );

stdout_is() captures output sent to STDOUT from $coderef and compares
it against $expected. The test passes if equal.

stdout_isnt() passes if STDOUT is not equal to $expected.

=cut

sub stdout_is {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stdout=stdout_from($test);

  my $ok=($stdout eq $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT is:\n$stdout\nnot:\n$expected\nas expected" ) unless($ok);

  return $ok;
}

sub stdout_isnt {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stdout=stdout_from($test);

  my $ok=($stdout ne $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT:\n$stdout\nmatching:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

=head2 stdout_like stdout_unlike

   stdout_like  ( $coderef, qr/$expected/, 'comment' );
   stdout_unlike( $coderef, qr/$expected/, 'comment' );

stdout_like() captures the output sent to STDOUT from $coderef and compares
it to the regex in $expected. The test passes if the regex matches.

stdout_unlike() passes if STDOUT does not match the regex.

=cut

sub stdout_like {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $usable_regex=$Test->maybe_regex( $expected );
  unless(defined( $usable_regex )) {
    my $ok = $Test->ok( 0, 'stdout_like' );
    $Test->diag("'$expected' doesn't look much like a regex to me.");
    return $ok;
  }

  my $stdout=stdout_from($test);

  my $ok=($stdout =~ $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT:\n$stdout\ndoesn't match:\n$expected\nas expected" ) unless($ok);

  return $ok;
}

sub stdout_unlike {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $usable_regex=$Test->maybe_regex( $expected );
  unless(defined( $usable_regex )) {
    my $ok = $Test->ok( 0, 'stdout_unlike' );
    $Test->diag("'$expected' doesn't look much like a regex to me.");
    return $ok;
  }

  my $stdout=stdout_from($test);

  my $ok=($stdout !~ $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT:\n$stdout\nmatches:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

=head2 stderr_is stderr_isnt

   stderr_is  ( $coderef, $expected, 'comment' );
   stderr_isnt( $coderef, $expected, 'comment' );

stderr_is() is similar to stdout_is, except that it captures STDERR. The
test passes if STDERR from $coderef equals $expected.

stderr_isnt() passes if STDERR is not equal to $expected.

=cut

sub stderr_is {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stderr=stderr_from($test);

  my $ok=($stderr eq $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDERR is:\n$stderr\nnot:\n$expected\nas expected" ) unless($ok);

  return $ok;
}

sub stderr_isnt {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stderr=stderr_from($test);

  my $ok=($stderr ne $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDERR:\n$stderr\nmatches:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

=head2 stderr_like stderr_unlike

   stderr_like  ( $coderef, qr/$expected/, 'comment' );
   stderr_unlike( $coderef, qr/$expected/, 'comment' );

stderr_like() is similar to stdout_like() except that it compares the regex 
$expected to STDERR captured from $codref. The test passes if the regex
matches.

stderr_unlike() passes if STDERR does not match the regex.

=cut

sub stderr_like {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $usable_regex=$Test->maybe_regex( $expected );
  unless(defined( $usable_regex )) {
    my $ok = $Test->ok( 0, 'stderr_like' );
    $Test->diag("'$expected' doesn't look much like a regex to me.");
    return $ok;
  }

  my $stderr=stderr_from($test);

  my $ok=($stderr =~ $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDERR:\n$stderr\ndoesn't match:\n$expected\nas expected" ) unless($ok);

  return $ok;
}

sub stderr_unlike {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $usable_regex=$Test->maybe_regex( $expected );
  unless(defined( $usable_regex )) {
    my $ok = $Test->ok( 0, 'stderr_unlike' );
    $Test->diag("'$expected' doesn't look much like a regex to me.");
    return $ok;
  }

  my $stderr=stderr_from($test);

  my $ok=($stderr !~ $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDERR:\n$stderr\nmatches:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

=head2 output_is output_isnt

   output_is  ( $coderef, $expected_stdout, $expected_stderr, 'comment' );
   output_isnt( $coderef, $expected_stdout, $expected_stderr, 'comment' );

The output_is() function is a combination of the stdout_is() and stderr_is()
functions. For example:

  output_is(sub {print "foo"; print STDERR "bar";},'foo','bar');

is functionally equivalent to

  stdout_is(sub {print "foo";},'foo') 
    && stderr_is(sub {print STDERR "bar";'bar');

Unlike, stdout_is() and stderr_is() which ignore STDERR and STDOUT
repectively, output_is() requires both STDOUT and STDERR to match in order
to pass. Setting either $expected_stdout or $expected_stderr to C<undef>
ignores STDOUT or STDERR respectively.

  output_is(sub {print "foo"; print STDERR "bar";},'foo',undef);

is the same as

  stdout_is(sub {print "foo";},'foo') 

output_isnt() provides the opposite function of output_is(). It is a 
combination of stdout_isnt() and stderr_isnt().

  output_isnt(sub {print "foo"; print STDERR "bar";},'bar','foo');

is functionally equivalent to

  stdout_is(sub {print "foo";},'bar') 
    && stderr_is(sub {print STDERR "bar";'foo');

As with output_is(), setting either $expected_stdout or $expected_stderr to
C<undef> ignores the output to that facility.

  output_isnt(sub {print "foo"; print STDERR "bar";},undef,'foo',);

is the same as

  stderr_is(sub {print STDERR "bar";},'foo') 

=cut

sub output_is {
  my $test=shift;
  my $expout=shift;
  my $experr=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my($stdout,$stderr)=output_from($test);

  my $ok;

  if(defined($experr) && defined($expout)) {
     $ok=($stdout eq $expout) && ($stderr eq $experr);
   } elsif(defined($expout)) {
     $ok=($stdout eq $expout);
   } elsif(defined($experr)) {
     $ok=($stderr eq $experr);
   } else {
     $ok=($stderr eq '') && ($stdout eq '');
   }

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT is:\n$stdout\nnot:\n$expout\nas expected\n",
               "STDERR is:\n$stderr\nnot:\n$experr\nas expected" ) unless($ok);

  return $ok;
}

sub output_isnt {
  my $test=shift;
  my $expout=shift;
  my $experr=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my($stdout,$stderr)=output_from($test);

  my $ok;

  if(defined($experr) && defined($expout)) {
     $ok=($stdout ne $expout) && ($stderr ne $experr);
   } elsif(defined($expout)) {
     $ok=($stdout ne $expout);
   } elsif(defined($experr)) {
     $ok=($stderr ne $experr);
   } else {
     $ok=($stderr ne '') && ($stdout ne '');
   }

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT:\n$stdout\nmatching:\n$expout\nnot expected\n",
               "STDERR:\n$stderr\nmatching:\n$experr\nnot expected" ) unless($ok);

  return $ok;
}

sub output_from {
  my $test=shift;

  select((select(STDOUT), $|=1)[0]);
  select((select(STDERR), $|=1)[0]);
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

sub stderr_from {
  my $test=shift;

  select((select(STDERR), $|=1)[0]);
  my $err=tie *STDERR, 'Test::Output::Tie';

  &$test;
  my $stderr=$err->read;

  undef $err;
  untie *STDERR;

  return $stderr;
}

sub stdout_from {
  my $test=shift;

  select((select(STDOUT), $|=1)[0]);
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
