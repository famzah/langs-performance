package main

import (
	"fmt"
	"math"
)

func getPrimes7(n int) []int {
	if n < 2 {
		return []int{}
	}
	if n == 2 {
		return []int{2}
	}

	s := make([]int, 0, n/2)
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

	res := make([]int, 0, n/int(math.Log(float64(n))))
	res = append(res, 2)
	for _, v := range s {
		if v != 0 {
			res = append(res, v)
		}
	}

	return res
}

func main() {
	var res []int
	for i := 0; i < 10; i++ {
		res = getPrimes7(10000000)
		fmt.Printf("Found %d prime numbers.\n", len(res))
	}
}
