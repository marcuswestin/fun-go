package async

import (
	"fmt"
	"math/rand"
	"time"
)

func ExampleEach() {
	items := []string{"Foo", "Bar", "Cat"}
	var check map[string]bool
	err := Each(items, func(item string) error {
		time.After(rand.Float32() * time.Second)
		check[item] = true
	})
	assert(check["Foo"])
	assert(check["Bar"])
	assert(check["Cat"])
}

func assert(t bool) {
	if t {
		return
	}
	panic("assert failed")
}
