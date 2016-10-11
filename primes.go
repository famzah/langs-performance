package main

import (
	"fmt"
	"math"
	"os"
	"time"
)

func getPrimes7(n int) []int {
	if n < 2 {
		return []int{}
	}
	if n == 2 {
		return []int{2}
	}

	s := []int{}
	for i := 3; i <= n; i += 2 {
		s = append(s, i)
	}

	var j int
	m := 3
	mroot := int(math.Sqrt(float64(n)))
	half := len(s)
	for i := 0; m <= mroot; {
		if s[i] != 0 {
			j = (m*m - 3) / 2
			s[j] = 0
			for j < half {
				s[j] = 0
				j += m
			}
		}
		i++
		m = 2*i + 3
	}

	res := []int{}
	res = append(res, 2)
	for _, v := range s {
		if v != 0 {
			res = append(res, v)
		}
	}

	return res
}

func main() {
	var startTime = time.Now()
	var periodTime, _ = time.ParseDuration(os.Getenv("RUN_TIME") + "s")

	var res []int

	for time.Since(startTime) < periodTime {
		res = getPrimes7(10000000)
		fmt.Printf("Found %d prime numbers.\n", len(res))
	}
}
