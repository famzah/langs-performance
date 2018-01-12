import Foundation

func get_primes7(_ n: Int) -> [Int] {
  if n < 2 {
    return []
  } else if n == 2 {
    return [2]
  }

  // do only odd numbers starting at 3
  var s = Array(stride(from: 3, to: n, by: 2))

  let mroot: Int = Int(sqrt(Double(n)))
  let half = s.count
  var i = 0
  var m = 3
  while m <= mroot {
    if s[i] != 0 {
      var j: Int = (m*m - 3) / 2
      s[j] = 0
      while j < half {
        s[j] = 0
        j += m
      }
    }
    i += 1
    m = 2*i + 3
  }
  return [2] + s.filter { $0 != 0 }
}

if let period_time_var = ProcessInfo.processInfo.environment["RUN_TIME"] {
  let start_time = Date()
  let period_time = Int(period_time_var)!

  while Int(Date().timeIntervalSince(start_time)) < period_time {
    let res = get_primes7(10_000_000)
    print("Found \(res.count) prime numbers.")
  }
} else {
  print("RUN_TIME not found.")
}

