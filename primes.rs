use std::env;
use std::time::{Instant, Duration};

const PRIMES_COUNT: u32 = 10000000;

fn get_primes7(count: u32) -> Vec<u32> {
    if count < 2 {
        return vec![];
    } else if count == 2 {
        return vec![2];
    }

    let mut s = Vec::new();
    let mut i = 3;
    while i < count+1 {
        s.push(i);
        i += 2;
    }

    let mroot = (count as f32).sqrt() as u32;
    let half = s.len() as u32;

    let mut i: u32 = 0;
    let mut m: u32 = 3;

    while m <= mroot {
        if s.get(i as usize).is_some() && s[i as usize] != 0 {
            let mut j = (m*m-3)/2;
            s[j as usize] = 0;
            while j < half {
                s[j as usize] = 0;
                j += m;
            }
        }
        i += 1;
        m = 2*i+3;
    }

    let mut res = Vec::new();
    res.push(2);
    res.extend(s.into_iter().filter(|x| *x != 0));
    res
}

fn main() {
    let run_time_secs = match env::var("RUN_TIME") {
        Ok(v) => match v.parse::<u32>() {
            Ok(i) => i,
            Err(err) => panic!("RUN_TIME environment variable error: {}", err),
        },
        Err(err) => panic!("RUN_TIME environment variable error: {}", err),
    };

    let run_time = Duration::new(run_time_secs as u64, 0);
    let start = Instant::now();

    while start.elapsed() < run_time {
	    let primes = get_primes7(PRIMES_COUNT);
        println!("Found {} prime numbers.", primes.len());
    }
}

