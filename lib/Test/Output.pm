package Test::Output;

use warnings;
use strict;

use Test::Builder;
use Test::Output::Tie;
require Exporter;

our @ISA=qw(Exporter);
our @EXPORT=qw(output_is output_isnt 
               stderr_is stderr_isnt stderr_like stderr_unlike
               stdout_is stdout_isnt stdout_like stdout_unlike
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
    
    output_is(
              \&writer,
              "Write out.\n",
              "Error out.\n",
              'Test STDOUT & STDERR'
            );

    stdout_is(\&writer,"Write out.\n",'Test STDOUT');

    stderr_isnt(sub { print "This is STDOUT\n"; writer(); },
              "No error out.\n",'Test STDERR');

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

=head2 output_is output_isnt

   output_is  ( $coderef, $expected_stdout, $expected_stderr, 'comment' );
   output_isnt( $coderef, $expected_stdout, $expected_stderr, 'comment' );

output_is() compares the output of $coderef to 
$expected_stdout and $expected_stderr, and fails if they do not match.
output_isnt() being the opposite fails if they do match.

In output_isnt() setting either $expected_stdout or $expected_stderr 
to C<undef> ignores STDOUT or STEDERR during the test.

=cut

sub output_is {
  my $test=shift;
  my $expout=shift;
  my $experr=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my($stdout,$stderr)=_errandout($test);

  my $ok;

  if(defined($experr) && defined($expout)) {
     $ok=($stdout eq $expout) && ($stderr eq $experr);
   } elsif(defined($expout)) {
     $ok=($stdout eq $expout) && ($stderr eq '');
   } else {
     $ok=($stderr eq $experr) && ($stdout eq '');
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

  my($stdout,$stderr)=_errandout($test);

  my $ok;

  if(defined($experr) && defined($expout)) {
     $ok=($stdout ne $expout) && ($stderr ne $experr);
   } elsif(defined($expout)) {
     $ok=($stdout ne $expout) && ($stderr eq '');
   } else {
     $ok=($stderr ne $experr) && ($stdout eq '');
   }

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT:\n$stdout\nmatching:\n$expout\nnot expected\n",
               "STDERR:\n$stderr\nmatching:\n$experr\nnot expected" ) unless($ok);

  return $ok;
}

=head2 stdout_is stdout_isnt

   stdout_is  ( $coderef, $expected, 'comment' );
   stdout_isnt( $coderef, $expected, 'comment' );

stdout_is() is similar to output_is() except that it only compares 
$expected to STDOUT captured from $codref. stdout_isnt() is the opposite.

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

sub stdout_isnt {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stdout=_out($test);

  my $ok=($stdout ne $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT:\n$stdout\nmatching:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

=head2 stdout_like stdout_unlike

   stdout_like  ( $coderef, qr/$expected/, 'comment' );
   stdout_unlike( $coderef, qr/$expected/, 'comment' );

stdout_like() is similar to output_like(), except that it only compares 
the regex $expected to STDOUT captured from $codref. stdout_unlike() 
being the opposite.

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

  my $stdout=_out($test);

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

  my $stdout=_out($test);

  my $ok=($stdout !~ $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDOUT:\n$stdout\nmatches:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

=head2 stderr_is stderr_isnt

   stderr_is  ( $coderef, $expected, 'comment' );
   stderr_isnt( $coderef, $expected, 'comment' );

stderr_is() is similar to output_is(), and stdout_is() except that it only
compares $expected to STDERR captured from $codref. Again stderr_isnt() is
the opposite.

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

sub stderr_isnt {
  my $test=shift;
  my $expected=shift;
  my $options=shift if(ref($_[0]));
  my $comment=shift;

  my $stderr=_err($test);

  my $ok=($stderr ne $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDERR:\n$stderr\nmatches:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

=head2 stderr_like stderr_unlike

   stderr_like  ( $coderef, qr/$expected/, 'comment' );
   stderr_unlike( $coderef, qr/$expected/, 'comment' );

stderr_like() is similar to output_like(), and stdout_like() except that 
it only compares the regex $expected to STDERR captured from $codref. 
stderr_unlike() being the opposite.

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

  my $stderr=_err($test);

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

  my $stderr=_err($test);

  my $ok=($stderr !~ $expected);

  $Test->ok( $ok, $comment );
  $Test->diag( "STDERR:\n$stderr\nmatches:\n$expected\nnot expected" ) unless($ok);

  return $ok;
}

sub _errandout {
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

sub _err {
  my $test=shift;

  select((select(STDERR), $|=1)[0]);
  my $err=tie *STDERR, 'Test::Output::Tie';

  &$test;
  my $stderr=$err->read;

  undef $err;
  untie *STDERR;

  return $stderr;
}

sub _out {
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
