package fun

import (
	"testing"
)

func TestFirstAndLastWithStrings(t *testing.T) {
	empty := []string{}
	one := []string{"1"}
	three := []string{"1", "2", "3"}
	var nilSlice []string = nil
	assert(t, First(empty) == "")
	assert(t, First(one) == "1")
	assert(t, First(three) == "1")
	assert(t, Last(empty) == "")
	assert(t, Last(one) == "1")
	assert(t, Last(three) == "3")
	assert(t, First(nilSlice) == "")
}

type testStruct struct{}

func TestFirstAndLastWithStructs(t *testing.T) {
	first := testStruct{}
	last := testStruct{}
	one := []testStruct{first}
	three := []testStruct{first, testStruct{}, last}
	assert(t, First(one) == first)
	assert(t, First(three) == first)
	assert(t, Last(one) == first)
	assert(t, Last(three) == last)
}

func TestFirstAndLastWithPtrs(t *testing.T) {
	empty := []*testStruct{}
	one := []*testStruct{&testStruct{}}
	three := []*testStruct{&testStruct{}, &testStruct{}, &testStruct{}}
	var nilSlice []*testStruct = nil
	assert(t, First(empty).(*testStruct) == nil)
	assert(t, First(one).(*testStruct) != nil)
	assert(t, First(three).(*testStruct) != nil)
	assert(t, Last(empty).(*testStruct) == nil)
	assert(t, Last(one).(*testStruct) != nil)
	assert(t, Last(three).(*testStruct) != nil)
	assert(t, First(nilSlice).(*testStruct) == nil)
}
