package async

import (
	"math/rand"
	"time"

	"github.com/marcuswestin/fun-go/errs"
)

func ExampleEach() {
	items := []string{"Foo", "Bar", "Cat"}
	var check map[string]bool
	err := Each(items, func(item string) errs.Err {
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
