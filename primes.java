import java.util.*;
import java.lang.Math;

class PrimeNumbersGenerator {
	ArrayList<Integer> get_primes7(int n) {
		ArrayList<Integer> res = new ArrayList<Integer>();

		if (n < 2) return res;
		if (n == 2) {
			res.add(2);
			return res;
		}
		ArrayList<Integer> s = new ArrayList<Integer>();
		for (int i = 3; i < n + 1; i += 2) {
			s.add(i);
		}
		int mroot = (int)Math.sqrt(n);
		int half = s.size();
		int i = 0;
		int m = 3;
		while (m <= mroot) {
			if (s.get(i) != 0) {
				int j = (int)((m*m - 3)/2);
				s.set(j, 0);
				while (j < half) {
					s.set(j, 0);
					j += m;
				}
			}
			i = i + 1;
			m = 2*i + 3;
		}
		res.add(2);
		for (int it = 0; it < s.size(); ++it) {
			if (s.get(it) != 0) {
				res.add(s.get(it));
			}
		}

		return res;
	}
}

class PrimeNumbersBenchmarkApp {
	public static void main(String[] args) {
		ArrayList<Integer> res;
		for (int i = 1; i <= 10; ++i) {
			res = (new PrimeNumbersGenerator()).get_primes7(10000000);
			System.out.format("Found %d prime numbers.\n", res.size());
		}
	}
}
