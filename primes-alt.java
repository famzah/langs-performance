import java.util.*;
import java.lang.Math;

class PrimeNumbersGenerator {
	IntList get_primes7(int n) {
		IntList res = new IntList();

		if (n < 2) return res;
		if (n == 2) {
			res.add(2);
			return res;
		}
		IntList s = new IntList();
		for (int i = 3; i <= n; i += 2) {
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
		for (int it = 0; it < s.data.length; ++it) {
			if (s.data[it] != 0) {
				res.add(s.data[it]);
			}
		}

		return res;
	}
}

/*
* Variable length int ArrayList.
* 
* (Like the Java java.util.ArrayList.
* Just without the slow java.lang.Integer unboxing/boxing)
*/
class IntList {

	private static final int DEFAULT_CAPACITY = 1000;
	public int[] data;
	private int off = 0;

	public IntList() {
		data = new int[DEFAULT_CAPACITY];
	}

	public void add(int x) {
		// if there is not enough room to store the value a new array is created.
		// (like in java.lang.ArrayList)
		if (off >= data.length) {
			data = Arrays.copyOf(data, data.length * 2);
		}
		data[off++] = x;
	}

	public void clear() {
		off = 0;
	}

	public int size() {
		return off;
	}

	public void set(int i, int x) {
		data[i] = x;
	}

	public int get(int x) {
		return data[x];
	}
}

class PrimeNumbersBenchmarkApp {
	public static void main(String[] args) {
		long startTime = System.currentTimeMillis();
		long periodTime = Long.parseLong(System.getenv("RUN_TIME"), 10) * 1000;

		IntList res;

		while ((System.currentTimeMillis() - startTime) < periodTime) {
			res = (new PrimeNumbersGenerator()).get_primes7(10000000);
			System.out.format("Found %d prime numbers.\n", res.size());
		}
	}
}
