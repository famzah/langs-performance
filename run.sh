#!/bin/bash

EXPSTR='Found 664579 prime numbers.'
RUN_TIME=90 # CPU time seconds

echo "# Run time limited to $RUN_TIME CPU seconds"
echo "#"

function run_benchmark() {
	HEADER="$1"
	COMPILE_CMD="$2"
	RUN_CMD="$3"
	VERSION_CMD="$4"
	VERSION_FILTER_CMD="$5"

	$VERSION_CMD >/dev/null 2>&1
	if [ "$?" == 127 ]; then # "command not found"
		echo "SKIPPING: $HEADER / $VERSION_CMD" >&2
		return # skip non-existing interpreter
	fi

	VERSION_OUT="$( $VERSION_CMD 2>&1 | $VERSION_FILTER_CMD | tr '\n' ' ' )"

	echo "# $HEADER"

	echo "# ... compilation"
	$COMPILE_CMD || exit 1 # compilation failed

	for n in {1..2}; do
		echo "# ... run $n"

		TIMES_FILE="$(mktemp --suffix .langs_perf)" || exit 1

		# force unbuffered output by using "stdbuf" or else we lose the output on SIGKILL
		OUT="$(
		{
			ulimit -t "$RUN_TIME" || exit 1
			/usr/bin/time -o "$TIMES_FILE" --format \
				'real_TIME:%esec user_CPU:%Usec sys_CPU:%Ssec max_RSS:%Mkb swaps:%W ctx_sw:%c+%w' \
				stdbuf -o0 -e0 $RUN_CMD
		} 2>&1
		)"

		TIMES_OUT="$(cat "$TIMES_FILE" | grep -vx 'Command terminated by signal 9')"
		rm "$TIMES_FILE"

		# check that all scripts output the same lines
		if [ "$(echo "$OUT" | grep -xv "$EXPSTR")" != '' ]; then
			echo "ERROR: Unexpected output: $OUT" >&2
			exit 1
		fi

		NLINES="$(echo "$OUT"|wc -l)"
		if [ "$NLINES" -lt 10 ]; then
			echo "ERROR: Not enough successful loops: $NLINES" >&2
			echo "$OUT" >&2
			exit 1
		fi

		echo "$TIMES_OUT nlines:$NLINES run_try:$n header:'$HEADER' version:'$VERSION_OUT'"
	done
}

C='g++'		; run_benchmark 'C++ (optimized with -O2)' "$C -Wall -O2 primes.cpp -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1'
rm -f ./primes.cpp.out
C='g++'		; run_benchmark 'C++ (not optimized)' "$C -Wall primes.cpp -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1'
rm -f ./primes.cpp.out
C='go'	; run_benchmark 'Go (not optimized, default compiler)' "$C build primes.go" './primes' "$C version" 'cat'
go clean
C='pypy'	; run_benchmark 'PyPy 2.7' 'true' "$C ./primes.py" "$C -V" 'cat'
C='python2.7'	; run_benchmark 'Python 2.7' 'true' "$C ./primes.py" "$C -V" 'cat'
C='python3.2'	; run_benchmark 'Python 3.2' 'true' "$C ./primes.py" "$C -V" 'cat'
C='python3.5'	; run_benchmark 'Python 3.5' 'true' "$C ./primes.py" "$C -V" 'cat'
C='perl'	; run_benchmark 'Perl' 'true' "$C ./primes.pl" "$C -v" 'grep built'
C='php5.6'	; run_benchmark 'PHP 5.6' 'true' "$C ./primes.php" "$C -v" 'head -n1'
C='php7.0'	; run_benchmark 'PHP 7.0' 'true' "$C ./primes.php" "$C -v" 'head -n1'
C='javac'	; run_benchmark 'Java (std)' "$C primes.java" 'java PrimeNumbersBenchmarkApp' "$C -version" 'cat'
rm -f PrimeNumbersBenchmarkApp.class PrimeNumbersGenerator.class
C='javac'	; run_benchmark 'Java (non-std)' "$C primes-non-std-lib.java" 'java PrimeNumbersBenchmarkApp' "$C -version" 'cat'
rm -f PrimeNumbersBenchmarkApp.class PrimeNumbersGenerator.class IntList.class
C='node'	; run_benchmark 'JavaScript (nodejs)' 'true' "$C ./primes.js" "$C -v" 'cat'
C='nodejs'	; run_benchmark 'JavaScript (nodejs)' 'true' "$C ./primes.js" "$C -v" 'cat'
C='ruby'	; run_benchmark 'Ruby' 'true' "$C ./primes.rb" "$C -v" 'cat'
