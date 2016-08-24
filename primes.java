import java.util.*;
import java.lang.Math;

class PrimeNumbersGenerator {
    int[] get_primes7(int n) {
        int[] res;

        if (n < 2)
            return new int[0];
        if (n == 2) {
            res = new int[1];
            res[0] = 2;
            return res;
        }

        int[] s = new int[(n + 1 - 3) / 2];
        int prime_idx = 0;
        for (int i = 3; i < n + 1; i += 2) {
            s[prime_idx] = i;
            prime_idx++;
        }

        int mroot = (int) Math.sqrt(n);
        int half = s.length;
        int i = 0;
        int m = 3;
        while (m <= mroot) {
            if (s[i] != 0) {
                int j = (int) ((m * m - 3) / 2);
                s[j] = 0;
                while (j < half) {
                    s[j] = 0;
                    j += m;
                }
            }
            i = i + 1;
            m = 2 * i + 3;
        }

        int res_size = 1;
        for (int it = 0; it < s.length; ++it) {
            if (s[it] != 0) {
                res_size++;
            }
        }

        res = new int[res_size];
        res[0] = 2;
        prime_idx = 1;

        for (int it = 0; it < s.length; ++it) {
            if (s[it] != 0) {
                res[prime_idx] = s[it];
                prime_idx++;
            }
        }

        return res;
    }
}

class PrimeNumbersBenchmarkApp {
	public static void main(String[] args) {
        int[] res;
		for (int i = 1; i <= 10; ++i) {
            res = (new PrimeNumbersGenerator2()).get_primes7(10000000);
            System.out.format("Found %d prime numbers.\n", res.length);
		}
	}
}
