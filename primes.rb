require 'time'

def get_primes7(n)
  return [] if n  < 2
  return [2] if n == 2

  # do only odd numbers starting at 3
  s = 3.upto(n + 1).select(&:odd?)

  mroot = n ** 0.5
  half = s.length
  i = 0
  m = 3
  until m > mroot do
    if s[i]
      j = (m * m - 3) / 2
      s[j] = nil
      until j >= half do
        s[j] = nil
        j += m
      end
    end
    i += 1
    m = 2 * i + 3
  end
  [2] + s.compact
end

startTime = Time.now.to_i
periodTime = ENV['RUN_TIME'].to_i

while (Time.now.to_i - startTime) < periodTime do
  res = get_primes7(10000000)
  puts "Found #{res.length} prime numbers."
end
