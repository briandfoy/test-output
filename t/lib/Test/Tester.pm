# $Header: /home/fergal/my/cvs/Test-Tester/lib/Test/Tester.pm,v 1.24 2003/07/27 20:01:03 fergal Exp $
use strict;

package Test::Tester;

use Test::Builder;
use Test::Tester::CaptureRunner;
use Test::Tester::Delegate;

require Exporter;

use vars qw( @ISA @EXPORT $VERSION );

$VERSION = "0.09";
@EXPORT = qw( run_tests check_tests check_test cmp_results );
@ISA = qw( Exporter );

my $Test = Test::Builder->new;
my $Capture = Test::Tester::Capture->new;
my $Delegator = Test::Tester::Delegate->new;
$Delegator->{Object} = $Test;

my $runner = Test::Tester::CaptureRunner->new;

sub new_new
{
	return $Delegator;
}

sub capture
{
	return Test::Tester::Capture->new;
}

sub fh
{
	# experiment with capturing output, I don't like it
	$runner = Test::Tester::FHRunner->new;

	return $Test;
}

sub find_run_tests
{
	my $d = 1;
	my $found = 0;
	while ((not $found) and (my ($sub) = (caller($d))[3]) )
	{
#		print "$d: $sub\n";
		$found = ($sub eq "Test::Tester::run_tests");
		$d++;
	}

#	die "Didn't find 'run_tests' in caller stack" unless $found;
	return $d;
}

sub run_tests
{
	local($Delegator->{Object}) = $Capture;

	$runner->run_tests(@_);

	return ($runner->get_premature, $runner->get_results);
}

sub check_test
{
	my $test = shift;
	my $expect = shift;
	my $name = shift;
	$name = "" unless defined($name);

	@_ = ($test, [$expect], $name);
	goto &check_tests;
}

sub check_tests
{
	my $test = shift;
	my $expects = shift;
	my $name = shift;
	$name = "" unless defined($name);

	my ($prem, @results) = eval { run_tests($test, $name) };

	$Test->ok(! $@, "Test '$name' completed") || $Test->diag($@);
	$Test->ok(! length($prem), "Test '$name' no premature diagostication") ||
		$Test->diag("Before any testing anything, your tests said\n$prem");

	local $Test::Builder::Level = $Test::Builder::Level + 1;
	cmp_results(\@results, $expects, $name);
	return ($prem, @results);
}

sub cmp_field
{
	my ($result, $expect, $field, $desc) = @_;

	if (defined $expect->{$field})
	{
		$Test->is_eq($result->{$field}, $expect->{$field},
			"$desc compare $field");
	}
}

sub cmp_result
{
	my ($result, $expect, $name) = @_;

	my $sub_name = $result->{name};
	$sub_name = "" unless defined($name);

	my $desc = "subtest '$sub_name' of '$name'";

	{
		local $Test::Builder::Level = $Test::Builder::Level + 1;

		cmp_field($result, $expect, "ok", $desc);

		cmp_field($result, $expect, "actual_ok", $desc);

		cmp_field($result, $expect, "type", $desc);

		cmp_field($result, $expect, "reason", $desc);

		cmp_field($result, $expect, "name", $desc);

		cmp_field($result, $expect, "depth", $desc);
	}

	if (defined $expect->{diag})
	{
		if (not $Test->ok($result->{diag} eq $expect->{diag},
			"subtest '$sub_name' of '$name' compare diag")
		)
		{
			my $glen = length($result->{diag});
			my $elen = length($expect->{diag});

			$Test->diag(<<EOM);
Got diag ($glen bytes):
$result->{diag}
Expected diag ($elen bytes):
$expect->{diag}
EOM

		}
	}
}

sub cmp_results
{
	my ($results, $expects, $name) = @_;

	$Test->is_num(scalar @$results, scalar @$expects, "Test '$name' result count");

	for (my $i = 0; $i < @$expects; $i++)
	{
		my $expect = $expects->[$i];
		my $result = $results->[$i];

		local $Test::Builder::Level = $Test::Builder::Level + 1;
		cmp_result($result, $expect, $name);
	}
}

######## nicked from Test::More
sub plan {
    my(@plan) = @_;

    my $caller = caller;

    $Test->exported_to($caller);

    my @imports = ();
    foreach my $idx (0..$#plan) {
        if( $plan[$idx] eq 'import' ) {
            my($tag, $imports) = splice @plan, $idx, 2;
            @imports = @$imports;
            last;
        }
    }

    $Test->plan(@plan);

    __PACKAGE__->_export_to_level(1, __PACKAGE__, @imports);
}

sub import {
    my($class) = shift;
		{
			no warnings 'redefine';
			*Test::Builder::new = \&new_new;
		}
    goto &plan;
}

sub _export_to_level
{
      my $pkg = shift;
      my $level = shift;
      (undef) = shift;                  # redundant arg
      my $callpkg = caller($level);
      $pkg->export($callpkg, @_);
}


############

1;

__END__

=head1 NAME

Test::Tester - Ease testing test modules built with Test::Builder

=head1 SYNOPSIS

  use Test::Tester tests => 5;

  use Test::MyStyle;

  check_test(
    sub {
      is_mystyle_eq("this", "that", "not eq");
    },
    {
      ok => 0, # expect this to fail
      name => "not eq",
      diag => "Expected: 'this'\nGot: 'that'",
    }
  );

or

  use Test::Tester;

  use Test::More tests => 2;
  use Test::MyStyle;

  my @results = run_tests(
    sub {
      is_database_alive("dbname");
    },
    {
      ok => 1, # expect the test to pass
    }
  );

  # now use Test::More::like to check the diagnostic output

  like($result[1]->{diag}, "/^Database ping took \\d+ seconds$"/, "diag");

=head1 DESCRIPTION

If you have written a test module based on Test::Builder then Test::Tester
allows you to test it with the minimum of effort.

=head1 HOW TO USE (THE EASY WAY)

From version 0.08 Test::Tester no longer requires you to included anything
special in your test modules. All you need to do is

  use Test::Tester;

in your test script before any other Test::Builder based modules and away
you go.

Other modules based on Test::Builder can be used to help with the testing.
In fact you can even use functions from your test module to test other
functions from the same module - although that may not be a very wise thing
to do!

The easiest way to test is to do something like

  check_test(
    sub { is_mystyle_eq("this", "that", "not eq") },
    {
      ok => 0, # we expect the test to fail
      name => "not eq",
      diag => "Expected: 'this'\nGot: 'that'",
    }
  );

this will execute the is_mystyle_eq test, capturing it's results and
checking that they are what was expected.

You may need to examine the test results in a more flexible way, for
example, if the diagnostic output may be quite complex or it may involve
something that you cannot predict in advance like a timestamp. In this case
you can get direct access to the test results:

  my @results = run_tests(
    sub {
      is_database_alive("dbname");
    },
    {
      ok => 1, # expect the test to pass
    }
  );

  like($result[1]->{diag}, "/^Database ping took \\d+ seconds$"/, "diag");


We cannot predict how long the database ping will take so we use
Test::More's like() test to check that the diagnostic string is of the right
form.

=head1 HOW TO USE (THE HARD WAY)

I<This is here for backwards compatibility only>

Make your module use the Test::Tester::Capture object instead of the
Test::Builder one. How to do this depends on your module but assuming that
your module holds the Test::Builder object in $Test and that all your test
routines access it through $Test then providing a function something like this

  sub set_builder
  {
    $Test = shift;
  }

should allow your test scripts to do

  Test::YourModule::set_builder(Test::Tester->capture);

and after that any tests inside your module will captured.

=begin _scrapped_for_now

=head1 HOW TO USE THE HORRIBLE NEW WAY

There is now another way to use this, maybe it's a better way, I don't know.
Just do a Test::Tester::fh() and it then it'll be set up to run in
filehandle capture mode. This means that when you run a test using one of
the functions provided below, the output form Test::Builder will be
captured. The results that are returned are exactly what you get from
Test::Builder's details method but each result also has it's diagnostic
output added to the hash under the 'diag' key. For failed tests, the failure
notice is removed.

This is another quite dodgy way of doing things as it fiddles with
Test::Builder's current_test counter and does nasty things to it's
@Test_Result array.

=end

=head1 TEST RESULTS

The result of each test is captured in a hash. These hashes are the same as
the hashes returned by Test::Builder->details but with a couple of extra
fields.

These fields are documented in L<Test::Builder> in the details() function

=over 2 

=item ok

Did the test pass?

=item actual_ok

Did the test really pass? That is, did the pass come from
Test::Builder->ok() or did it pass because it was a TODO test?

=item name

The name supplied for the test.

=item type

What kind of test? Possibilities include, skip, todo etc. See
L<Test::Builder> for more details.

=item reason

The reason for the skip, todo etc. See L<Test::Builder> for more details.

=back

These fields are exclusive to Test::Tester.

=over 2

=item diag

Any diagnostics that were output for the test. This only includes
diagnostics output B<after> the test result is declared.

=item depth

This allows you to check that your test module is setting the correct value
for $Test::Builder::Level and thus giving the correct file and line number
when a test fails. It is calculated by looking at caller() and
$Test::Builder::Level. It should count how many subroutines there are before
jumping into the function you are testing so for example in

  run_tests( sub { my_test_function("a", "b") } );

the depth should be 1 and in

  sub deeper { my_test_function("a", "b") }
  
  run_tests(sub { deeper() });

depth should be 2, that is 1 for the sub {} and one for deeper(). This might
seem a little complex but unless you are calling your test functions inside
subroutines or evals then depth will always be 1.

B<Note>: depth will not be correctly calculated for tests that run from a
signal handler or an END block or anywhere else that hides the call stack.

=back

Some of the Test::Testers functions return arrays of these hashes, just like
Test::Builder->details. That is, the hash for the first test will be array
element 1 (not 0). Element 0 will not be a hash it will be a string which
contains any diagnostic output that came before the first test. This should
usually be empty.

=head1 EXPORTED FUNCTIONS

=head3 ($prem, @results) = run_tests(\&test_sub, $name)

\&test_sub is a reference to a subroutine.

$name is a string.

run_tests runs the subroutine in $test_sub and captures the results of any
tests inside it. You can run more than 1 test inside this subroutine if you
like.

$prem is a string containg any diagnostic output from before the first test.

@results is an array of test result hashes.

=head3 cmp_result(\%result, \%expect, $name)

\%result is a ref to a test result hash.

\%expect is a ref to a hash of expected values for the test result.

cmp_result compares the result with the expected values. If any differences
are found it outputs diagnostics. You may leave out any field from the
expected result and cmp_result will not do the comparison of that field.

=head3 cmp_results(\@results, \@expects, $name)

\@results is a ref to an array of test results.

\@expects is a ref to an array of hash refs.

cmp_results checks that the results match the expected results and if any
differences are found it outputs diagnostics. It first checks that the
number of elements in \@results and \@expects is the same. Then it goes
through each result checking it against the expected result as in
cmp_result() above.

=head3 ($prem, @results) = check_tests(\&test_sub, \@expects, $name)

\&test_sub is a reference to a subroutine.

\@expect is a ref to an array of hash refs which are expected test results.

check_tests combines run_tests and cmp_tests into a single call. It also
checks if the tests died at any stage.

It returns the same values as run_tests, so you can further examine the test
results if you need to.

=head3 ($prem, @results) = check_test(\&test_sub, \%expect, $name)

\&test_sub is a reference to a subroutine. 

\%expect is a ref to an hash of expected values for the test result.

check_test is a wrapper around check_tests. It combines run_tests and
cmp_tests into a single call, checking if the test died. It assumes that
only a single test is run inside \&test_sub and test to make this is true.

It returns the same values as run_tests, so you can further examine the test
results if you need to.

=head1 HOW IT WORKS

Normally, a test module (let's call it Test:MyStyle) calls
Test::Builder->new to get the Test::Builder object. Test::MyStyle calls
methods on this object to record information about test results. When
Test::Tester is loaded, it replaces Test::Builder's new() method with one
which returns a Test::Tester::Delegate object. Most of the time this object
appears to be the real Test::Builder object. Any methods that are called are
delegated to the real Test::Builder object so everything works perfectly.
However once we go into test mode, the method calls are no longer passed to
the real Test::Builder object, instead they go to the Test::Tester::Capture
object. This object seems exactly like the real Test::Builder object,
except, instead of outputting test results and diagnostics, it just records
all the information for later analysis.

=head1 SEE ALSO

L<Test::Builder> the source of testing goodness. L<Test::Builder::Tester>
for an alternative approach to the problem tackled by Test::Tester -
captures the strings output by Test::Builder. This means you cannot get
separate access to the individual pieces of information and you must predict
B<exactly> what your test will output.

=head1 AUTHOR

This module is copyright 2004 Fergal Daly <fergal@esatclear.ie>, some parts
are based on other people's work.

Plan handling lifted from Test::More. written by Michael G Schwern
<schwern@pobox.com>.

Test::Tester::Capture is a cut down and hacked up version of Test::Builder.
Test::Builder was written by chromatic <chromatic@wgz.org> and Michael G
Schwern <schwern@pobox.com>.

=head1 LICENSE

Under the same license as Perl itself

See http://www.perl.com/perl/misc/Artistic.html

=cut
