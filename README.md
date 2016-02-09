# langs-performance
C++ vs. Python vs. Perl vs. PHP vs. Java vs. NodeJS performance benchmark

Blog articles:
* 2010-2012: http://blog.famzah.net/2010/07/01/cpp-vs-python-vs-perl-vs-php-performance-benchmark/

The benchmarks here do not try to be complete, as they are showing the performance of the languages in one aspect, and mainly: loops, dynamic arrays with numbers, basic math operations.

The times include the interpretation/parsing phase for each language, but it’s so small that its significance is negligible. The math function is called 10 times, in order to have more reliable results. All scripts are using the very same algorithm to calculate the prime numbers in a given range. The correctness of the implementation is not so important, as we just want to check how fast the languages perform. The original Python algorithm was taken from http://www.daniweb.com/code/snippet216871.html.
