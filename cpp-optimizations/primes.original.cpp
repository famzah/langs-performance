#include <cstdio>
#include <cmath>
#include <vector>

using namespace std;

vector<int> get_primes7(int n) { // ugly variable declarations but close to the other lang. syntaxes
	vector<int> res;

	if (n < 2) return res;
	if (n == 2) {
		res.push_back(2);
		return res;
	}
	vector<int> s;
	for (int i = 3; i < n + 1; i += 2) {
		s.push_back(i);
	}
	int mroot = sqrt(n);
	int half = (int)s.size();
	int i = 0;
	int m = 3;
	while (m <= mroot) {
		if (s[i]) {
			int j = (int)((m*m - 3)/2);
			s[j] = 0;
			while (j < half) {
				s[j] = 0;
				j += m;
			}
		}
		i = i + 1;
		m = 2*i + 3;
	}
	res.push_back(2);
	for (vector<int>::iterator it = s.begin() ; it < s.end(); ++it) {
		if (*it) {
			res.push_back(*it);
		}
	}

	return res;
}

int main() {
	vector<int> res;
	for (int i = 1; i <= 10; ++i) {
		res = get_primes7(10000000);
		printf("Found %d prime numbers.\n", (int)res.size());
	}

	return 0;
}
