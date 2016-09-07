#include <cstdio>
#include <cmath>
#include <vector>
#include <algorithm>
#include <cstdlib>
#include <ctime>

using namespace std;

// Some performance optimizations are commented out as an alternative implementation.
// See the comments by Vinicius Miranda for more information:
// http://blog.famzah.net/2010/07/01/cpp-vs-python-vs-perl-vs-php-performance-benchmark/#comment-5347

void get_primes7(int n, vector<int> &res) {
	if (n < 2) return;
	if (n == 2) {
		res.push_back(2);
		return;
	}
	vector<int> s;
	// 1 //s.reserve(n/2); // hint the compiler that we will use "n/2" elements in "s"
	// 2 //s.resize( static_cast<int>(n/2) ); // pre-allocate memory
	// 2 //int j = 0;
	for (int i = 3; i < n + 1; i += 2) {
		s.push_back(i);
		// 2 //s[j] = i;
		// 2 //++j;
	}
	// 2 //s.resize(j);
	int mroot = sqrt(n);
	int half = static_cast<int>(s.size());
	int i = 0;
	int m = 3;
	while (m <= mroot) {
		if (s[i]) {
			int j = static_cast<int>((m*m - 3)*0.5);
			s[j] = 0;
			while (j < half) {
				s[j] = 0;
				j += m;
			}
		}
		i = i + 1;
		m = 2*i + 3;
	}
	// 1 //res.reserve(n/log(n)); // "Prime number theorem" says that we expect this amount of primes
	res.push_back(2);

	/*
	// loop manually
	for (vector<int>::iterator it = s.begin() ; it < s.end(); ++it) {
		if (*it) {
			res.push_back(*it);
		}
	}
	*/

	// use standard methods instead of a loop
	std::vector<int>::iterator pend = std::remove(s.begin(), s.end(), 0);
	res.insert(res.begin() + 1, s.begin(), pend);
}

int main() {
	std::time_t startTime = std::time(NULL);
	std::time_t periodTime = (std::time_t) atoi(std::getenv("RUN_TIME"));

	while ((std::time(NULL) - startTime) < periodTime) {
		vector<int> res;
		get_primes7(10000000, res);
		printf("Found %d prime numbers.\n", (int)res.size());
	}

	return 0;
}
