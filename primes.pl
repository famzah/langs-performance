use strict;
use warnings;

sub get_primes7($) {
	my ($n) = @_;

	if ($n < 2) { return (); }
	if ($n == 2) { return (2); }
	# do only odd numbers starting at 3
	my @s = ();
	for (my $i = 3; $i < $n + 1; $i += 2) {
		push(@s, $i);
	}
	# n**0.5 simpler than math.sqr(n)
	my $mroot = $n ** 0.5;
	my $half = scalar @s;
	my $i = 0;
	my $m = 3;
	while ($m <= $mroot) {
		if ($s[$i]) {
			my $j = int(($m*$m - 3) / 2);
			$s[$j] = 0;
			while ($j < $half) {
				$s[$j] = 0;
				$j += $m;
			}
		}
		$i = $i + 1;
		$m = 2*$i + 3;
	}
	my @res = (2);
	foreach (@s) {
		push(@res, $_) if ($_);
	}
	return @res;
}

my $startTime = time();
my $periodTime = $ENV{'RUN_TIME'};

my @res;

while ((time() - $startTime) < $periodTime) {
	@res = get_primes7(10000000);
	print "Found ".(scalar @res)." prime numbers.\n";
}
