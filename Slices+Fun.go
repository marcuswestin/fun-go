package fun

import (
	"github.com/BurntSushi/ty"
	"reflect"
)

func Last(slice interface{}) (elem interface{}) {
	chk := ty.Check(
		new(func([]ty.A) ty.A),
		slice)
	vSlice, tElem := chk.Args[0], chk.Returns[0]

	if vSlice.IsNil() || vSlice.Len() == 0 {
		return reflect.Zero(tElem).Interface()
	}
	return vSlice.Index(vSlice.Len() - 1).Interface()
}

func First(slice interface{}) (elem interface{}) {
	chk := ty.Check(
		new(func([]ty.A) ty.A),
		slice)
	sliceVal, elemTyp := chk.Args[0], chk.Returns[0]

	if sliceVal.IsNil() || sliceVal.Len() == 0 {
		return reflect.Zero(elemTyp).Interface()
	}
	return sliceVal.Index(0).Interface()
}
