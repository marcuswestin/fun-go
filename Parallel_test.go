package fun

import (
	"fmt"
	"testing"
)

func ExampleParallel() {
	res, err := Parallel(p1, p2, p2, p1, p2)
	fmt.Println(err, res)
	// Output:
	// <nil> [From p1 From p2 From p2 From p1 From p2]
}

func TestParallel(t *testing.T) {
	res, err := Parallel(p1, p2, p2, p2, p1)
	if err != nil {
		t.Fail()
	}
	if res[0] != "From p1" {
		t.Fail()
	}
	if len(res) != 5 {
		t.Fail()
	}
}

func p1() (interface{}, error) {
	return "From p1", nil
}
func p2() (interface{}, error) {
	return "From p2", nil
}
