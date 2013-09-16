package fun

import (
	"github.com/BurntSushi/ty/fun"
)

func Map(xs, f interface{}) interface{} {
	return fun.Map(f, xs)
}
