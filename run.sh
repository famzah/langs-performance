#!/bin/bash

EXPSTR='Found 664579 prime numbers.'

function run_benchmark() {
	HEADER="$1"
	CMD1="$2"
	CMD2="$3"
	VERSION_CMD="$4"
	VERSION_FILTER_CMD="$5"

	echo "== $HEADER =="
	for n in {1..2}; do
		$CMD1 && OUT=$(time $CMD2)

		echo "$OUT" | grep -xv "$EXPSTR" # check that all scripts output the same lines

		NLINES=$(echo "$OUT"|wc -l)
		[ "$NLINES" == '10' ] || echo "Unexpected loops count: $NLINES"
	done
	echo

	$VERSION_CMD | $VERSION_FILTER_CMD
	echo
}

C='g++'		; run_benchmark 'C++ (optimized with -O2)' "$C -Wall -O2 primes.cpp -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1'
rm -f ./primes.cpp.out
C='g++'		; run_benchmark 'C++ (not optimized)' "$C -Wall primes.cpp -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1'
rm -f ./primes.cpp.out
C='python2.7'	; run_benchmark 'Python 2.7' 'true' "$C ./primes.py" "$C -V" 'cat'
C='python3.2'	; run_benchmark 'Python 3.2' 'true' "$C ./primes.py" "$C -V" 'cat'
C='perl'	; run_benchmark 'Perl' 'true' "$C ./primes.pl" "$C -v" 'grep built'
C='php'		; run_benchmark 'PHP' 'true' "$C ./primes.php" "$C -v" 'head -n1'
C='javac'	; run_benchmark 'Java (std)' "$C primes.java" 'java PrimeNumbersBenchmarkApp' "$C -version" 'cat'
rm -f PrimeNumbersBenchmarkApp.class PrimeNumbersGenerator.class
C='javac'	; run_benchmark 'Java (non-std)' "$C primes-non-std-lib.java" 'java PrimeNumbersBenchmarkApp' "$C -version" 'cat'
rm -f PrimeNumbersBenchmarkApp.class PrimeNumbersGenerator.class IntList.class
C='node'	; run_benchmark 'JavaScript (nodejs)' 'true' "$C ./primes.js" "$C -v" 'cat'
