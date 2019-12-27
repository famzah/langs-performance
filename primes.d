import std.algorithm;
import std.array;
import std.conv;
import std.datetime;
import std.math;
import std.process;
import std.range;
import std.stdio;

int[] get_primes7(int n){	
	if (n<2){
		return [];
	}
	if (n==2){
		return [2];
	}
	auto s = array(iota(3,n+1,2));
	auto mroot = sqrt(cast(float)n);
	auto half = s.length;
	auto i = 0;
	auto m = 3;
	while (m <= mroot){
		if (s[i] != 0){
			int j = (m * m - 3) / 2;
			s[j] = 0;
			while (j< half){
				s[j] = 0;
				j += m;
			}
		}
		i++;
		m = 2*i + 3;
	}
	return [2]~array(filter!(a => a!=0)(s));
}

void main(){
	auto start_time = Clock.currTime().toUnixTime();
	auto period_time = to!int(environment.get("RUN_TIME"));
	
	while(Clock.currTime().toUnixTime() - start_time < period_time){
		auto res = get_primes7(10_000_000);
		writeln("Found ", res.length, " prime numbers.");
	}
}