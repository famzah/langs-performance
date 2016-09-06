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
	SRC_FILE="$6"

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

		echo "$TIMES_OUT nlines:$NLINES run_try:$n "\
			"header:'$HEADER' version:'$VERSION_OUT' src_file:$SRC_FILE"
	done
}

C='g++'		; SRC='primes.cpp'      ; run_benchmark 'C++ (optimized with -O2)' "$C -Wall -O2 $SRC -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1' "$SRC"
rm -f ./primes.cpp.out

C='g++'		; SRC='primes.cpp'      ; run_benchmark 'C++ (not optimized)'      "$C -Wall     $SRC -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1' "$SRC"
rm -f ./primes.cpp.out

C='go'	; SRC='primes.go'               ; run_benchmark 'Go (not optimized, default compiler)' "$C build $SRC" './primes' "$C version" 'cat' "$SRC"
go clean

C='pypy'	; SRC='primes.py'       ; run_benchmark 'PyPy 2.7'   'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='python2.7'	; SRC='primes.py'       ; run_benchmark 'Python 2.7' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='python3.2'	; SRC='primes.py'       ; run_benchmark 'Python 3.2' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='python3.5'	; SRC='primes.py'       ; run_benchmark 'Python 3.5' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='perl'	; SRC='primes.pl'       ; run_benchmark 'Perl' 'true' "$C $SRC" "$C -v" 'grep built' "$SRC"
C='php5.6'	; SRC='primes.php'      ; run_benchmark 'PHP 5.6' 'true' "$C $SRC" "$C -v" 'head -n1' "$SRC"
C='php7.0'	; SRC='primes.php'      ; run_benchmark 'PHP 7.0' 'true' "$C $SRC" "$C -v" 'head -n1' "$SRC"

C='javac'	; SRC='primes.java'     ; run_benchmark 'Java (std)'     "$C $SRC" 'java PrimeNumbersBenchmarkApp' "$C -version" 'cat' "$SRC"
rm -f PrimeNumbersBenchmarkApp.class PrimeNumbersGenerator.class

C='javac'	; SRC='primes-alt.java' ; run_benchmark 'Java (non-std)' "$C $SRC" 'java PrimeNumbersBenchmarkApp' "$C -version" 'cat' "$SRC"
rm -f PrimeNumbersBenchmarkApp.class PrimeNumbersGenerator.class IntList.class

# Node.js has two different binary names; try both of them
C='node'	; SRC='primes.js'       ; run_benchmark 'JavaScript (nodejs)' 'true' "$C $SRC" "$C -v" 'cat' "$SRC"
C='nodejs'	; SRC='primes.js'       ; run_benchmark 'JavaScript (nodejs)' 'true' "$C $SRC" "$C -v" 'cat' "$SRC"

C='ruby'	; SRC='primes.rb'       ; run_benchmark 'Ruby' 'true' "$C $SRC" "$C -v" 'cat' "$SRC"
