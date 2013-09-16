package fun

import (
	"fmt"
)

func ExampleMap() {
	lens := Map([]string{"hi", "hoe", "silver-lining"}, func(str string) int {
		return len(str)
	}).([]int)
	fmt.Println(lens)
	// Output:
	// [2 3 13]
}
