# Performance notes

Java can be (a lot) faster than what we see it with its default interpeter settings:
* Initial heap size -- setting this larger than the default value will allow the ArrayList to grow more efficiently by pre-allocating a bigger memory block from the system. The "java" command-line argument is "-Xms500m".
* Heap and GC tuning -- we can control the ratio between the old and young generations. The "java" command-line argument is "-XX:NewRatio=1".
* Skip the unneeded boxing/unboxing -- this requires a more native Java implementation. See the source code of "[primes-alt.java](../primes-alt.java)".
* Use LinkedList -- it has O(1) complexity for adding elements. Benchmark tests however don't show significant improvement under Java 8, and under Java 7 we see a slow down of 59%.

These tweaks are not included in the Java benchmark test, because I wanted to test the default languages setup. I don't aim to fine-tune any of the implementations by optimizing them for the current task/algorithm. This is a generic test, not an attempt to complete the current task in the fastest possible way for each programming language.
