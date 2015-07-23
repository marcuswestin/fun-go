package fun

import (
	"errors"
	"fmt"
	"testing"

	"github.com/marcuswestin/fun-go/errs"
)

func ExampleParallel() {
	Parallel(f1, f2, f3, func(f1res, f2res string, f3res int, err errs.Err) {
		fmt.Println(f1res, f2res, f3res)
	})
	// Output:
	// From p1 From p2 123
}

func TestParallel(t *testing.T) {
	Parallel(f1, f2, f3, func(fromP1, fromP2 string, fromP3 int, err errs.Err) {
		if err != nil {
			t.Error("Got unexpeted errs.Err")
		}
		if fromP1 != "From p1" || fromP2 != "From p2" || fromP3 != 123 {
			t.Fail()
		}
	})
}

func TestParallelErr(t *testing.T) {
	Parallel(f1, fErr, f2, f3, func(fromP1, fromErr, fromP2 string, fromP3 int, err errs.Err) {
		if err == nil {
			t.Error("Got nil err")
		} else if err.Error() != "Error from fErr" {
			t.Error("Got incorrect errs.Err")
		}
	})
	Parallel(f1, f2, fErr2, f3, func(fromF1, fromF2, fromFErr2 string, fromF3 int, err errs.Err) {
		if err == nil {
			t.Error("Got nil err")
		} else if err.Error() != "Error2 from fErr2" {
			t.Error("Got incorrect errs.Err")
		}
	})
}

func TestParallelNumInPanic(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("Did not panic")
		}
	}()
	badParallelFunc := func(unexpectedArgIn int) (res string, err errs.Err) { return }
	Parallel(badParallelFunc, func(res string, err errs.Err) {})
}

func TestParallelTypeOutPanic(t *testing.T) {
	defer func() {
		r := recover()
		if r != "Parallel function number 0 returns a \"string\" but final function expects a \"int\"" {
			t.Error("Did not panic with the expected message")
		}
	}()
	badParallelOutputFun := func() (res string, err errs.Err) { return }
	Parallel(badParallelOutputFun, func(res int, err errs.Err) {})
}

func TestParallelFinalErrArgPanic(t *testing.T) {
	defer func() {
		if r := recover(); r != "Parallel final function's last argument type should be errs.Err but is int" {
			t.Error("Did not panic with the expected message")
		}
	}()

	Parallel(f1, f2, func(res1, res2 string, err int) {})
}

func TestParallelFinalFuncReturnsError(t *testing.T) {
	var err errs.Err
	err = Parallel(f1, f2, func(res1, res2 string, err errs.Err) {})
	assert(t, err == nil)
	err = Parallel(f1, fErr, func(res1, res2 string, err errs.Err) {})
	assert(t, err != nil)
	err = Parallel(f1, f2, func(res1, res2 string, err errs.Err) errs.Err { return nil })
	assert(t, err == nil)
	err = Parallel(f1, fErr, func(res1, res2 string, err errs.Err) errs.Err { return errors.New("A new errs.Err") })
	assert(t, err != nil)
	assert(t, err.Error() == "A new errs.Err")
	err = Parallel(f1, f2, func(res1, res2 string, err errs.Err) errs.Err { return nil })
	assert(t, err == nil)
}

func noErr() errs.Err     { return nil }
func blurghErr() errs.Err { return errors.New("Blurgh") }

func TestParallelNoFinalFunc(t *testing.T) {
	err := Parallel(noErr, noErr)
	assert(t, err == nil)
}

func TestParallelNoFinalFuncError(t *testing.T) {
	err := Parallel(noErr, blurghErr, noErr)
	assert(t, err != nil)
	assert(t, err.Error() == "Blurgh")
}

func assert(t *testing.T, shouldBeTrue bool) {
	if shouldBeTrue {
		return
	}
	t.Error("assert failed")
	// panic("assert failed")
}

func fErr2() (res string, err errs.Err) {
	err = errors.New("Error2 from fErr2")
	return
}

func fErr() (res string, err errs.Err) {
	err = errors.New("Error from fErr")
	return
}
func f3() (int, errs.Err) {
	return 123, nil
}
func f1() (string, errs.Err) {
	return "From p1", nil
}
func f2() (string, errs.Err) {
	return "From p2", nil
}
