#!/bin/bash
set -u

EXPSTR='Found 664579 prime numbers.'
RUN_TIME="${RUN_TIME:=90}" # wall-clock time seconds
RUN_TRIES="${RUN_TRIES:=6}" # number of identical runs
MIN_NLINES="${MIN_NLINES:=10}" # it's a fatal error if we get less than this number of output lines
SRC_FILTER="${SRC_FILTER:=x}" # if provided, execute only the given test
DRY_RUN="${DRY_RUN:=0}" # if enabled, do only the compilation phase

_OS="$(uname)"
if [ "$_OS" == "Linux" ]; then
    TIME_CMD="$(which time)"
elif [ "$_OS" == "Darwin" ]; then
    TIME_CMD="$(which gtime)"
fi

if [ "$TIME_CMD" == "" ]; then
    echo "Unable to find the GNU time command." >&2
    echo "If you are on a non-Linux OS such as Mac OS or *BSD you will need to install it separately." >&2
    exit -1
fi

export RUN_TIME

echo "# Run time limited to $RUN_TIME wall-clock seconds"
echo "#"
# Note: This increases the memory usage but should still provide linear performance.

function run_benchmark() {
	HEADER="$1"
	COMPILE_CMD="$2"
	RUN_CMD="$3"
	VERSION_CMD="$4"
	VERSION_FILTER_CMD="$5"
	SRC_FILE="$6"

	if [ "$SRC_FILTER" != 'x' ]; then
		if [ "$SRC_FILE" != "$SRC_FILTER" ]; then
			return
		fi
	fi

	$VERSION_CMD >/dev/null 2>&1
	if [ "$?" == 127 ]; then # "command not found"
		echo "SKIPPING: $HEADER / $VERSION_CMD" >&2
		return # skip non-existing interpreter
	fi

	VERSION_OUT="$( $VERSION_CMD 2>&1 | $VERSION_FILTER_CMD | tr '\n' ' ' )"

	echo "# $HEADER"

	echo "# ... compilation"
	$COMPILE_CMD || exit 1 # compilation failed

	for n in $(seq 1 "$RUN_TRIES"); do
		if [ "$DRY_RUN" -ne 0 ]; then
			continue
		fi

		echo "# ... run $n"

		TIMES_FILE="$(mktemp)" || exit 1

		OUT="$(
		{
			"$TIME_CMD" -o "$TIMES_FILE" --format \
				'real_TIME:%esec user_CPU:%Usec sys_CPU:%Ssec max_RSS:%Mkb swaps:%W ctx_sw:%c+%w' \
				$RUN_CMD
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
		if [ "$NLINES" -lt "$MIN_NLINES" ]; then
			echo "ERROR: Not enough successful loops: $NLINES" >&2
			echo "$OUT" >&2
			exit 1
		fi

		echo "$TIMES_OUT nlines:$NLINES run_try:$n "\
			"header:'$HEADER' version:'$VERSION_OUT' src_file:$SRC_FILE"
	done
}

##

C='g++' ; SRC='primes.cpp' ; run_benchmark 'C++ (optimized with -O2)' \
	"$C -Wall -O2 $SRC -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1' "$SRC"
rm -f ./primes.cpp.out

C='g++' ; SRC='primes.cpp' ; run_benchmark 'C++ (not optimized)' \
	"$C -Wall     $SRC -o primes.cpp.out" './primes.cpp.out' "$C --version" 'head -n1' "$SRC"
rm -f ./primes.cpp.out

##

C='go' ; SRC='primes.go'   ; run_benchmark 'Go' \
	"$C build $SRC" './primes' "$C version" 'cat' "$SRC"
go clean

##

C='swiftc' ; SRC='primes.swift'  ; run_benchmark 'Swift (optimized with -O)' \
	"$C $SRC -o primes.swift.out -O -swift-version 4" './primes.swift.out' "$C -version" 'head -n1' "$SRC"
rm -f ./primes.swift.out

C='swiftc' ; SRC='primes.swift'  ; run_benchmark 'Swift (not optimized)' \
	"$C $SRC -o primes.swift.out -swift-version 4" './primes.swift.out' "$C -version" 'head -n1' "$SRC"
rm -f ./primes.swift.out

##

C='pypy'      ; SRC='primes.py'  ; run_benchmark 'Python 2.7 + PyPy' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='python2.7' ; SRC='primes.py'  ; run_benchmark 'Python 2.7' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='python3.2' ; SRC='primes.py'  ; run_benchmark 'Python 3.2' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='python3.5' ; SRC='primes.py'  ; run_benchmark 'Python 3.5' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"
C='python3.6' ; SRC='primes.py'  ; run_benchmark 'Python 3.6' 'true' "$C $SRC" "$C -V" 'cat' "$SRC"

##

C='perl'      ; SRC='primes.pl'  ; run_benchmark 'Perl' 'true' "$C $SRC" "$C -v" 'grep built' "$SRC"

##

C='php5.6'    ; SRC='primes.php' ; run_benchmark 'PHP 5.6' 'true' "$C $SRC" "$C -v" 'head -n1' "$SRC"
C='php7.0'    ; SRC='primes.php' ; run_benchmark 'PHP 7.0' 'true' "$C $SRC" "$C -v" 'head -n1' "$SRC"

##

JF1='PrimeNumbersBenchmarkApp'
JF2='PrimeNumbersGenerator'
JF3='IntList'

C='javac' ; SRC='primes.java'     ; run_benchmark 'Java 8' \
	"$C $SRC" "java $JF1" "$C -version" 'cat' "$SRC"
rm -f ${JF1}.class ${JF2}.class

C='javac' ; SRC='primes-alt.java' ; run_benchmark 'Java 8 (non-std lib)' \
	"$C $SRC" "java $JF1" "$C -version" 'cat' "$SRC"
rm -f ${JF1}.class ${JF2}.class ${JF3}.class

##

# Node.js has two different binary names; try both of them
C='node'   ; SRC='primes.js' ; run_benchmark 'JavaScript (nodejs)' 'true' "$C $SRC" "$C -v" 'cat' "$SRC"
C='nodejs' ; SRC='primes.js' ; run_benchmark 'JavaScript (nodejs)' 'true' "$C $SRC" "$C -v" 'cat' "$SRC"

##

C='ruby' ; SRC='primes.rb' ; run_benchmark 'Ruby' 'true' "$C $SRC" "$C -v" 'cat' "$SRC"

##

# -C opt-level=3 is the default opt level for the code produced by the --release target.
C='rust'; SRC='primes.rs' ; run_benchmark 'Rust' 'rustc -C opt-level=3 -o primes.rs.out primes.rs' './primes.rs.out' 'rustc -V' 'head -n1' "$SRC"
rm -f primes.rs.out

##
cd dotnet || exit 1
C='dotnet' ; SRC='primes.dotnet' ; run_benchmark 'C# .NET Core Linux' \
	'util/build' 'util/run' "$C --version" 'cat' "$SRC"
rm -rf bin obj
cd .. || exit 1

##
C='ldc2' ; SRC='primes.d' ; run_benchmark 'D' \
	"$C -O -of primes.d.out $SRC" './primes.d.out' "$C -version" 'head -n1' "$SRC"
rm -f ./primes.d.out