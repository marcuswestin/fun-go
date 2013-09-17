package fun

import (
	"errors"
	"fmt"
	"testing"
)

func ExampleParallel() {
	Parallel(f1, f2, f3, func(f1res, f2res string, f3res int, err error) {
		fmt.Println(f1res, f2res, f3res)
	})
	// Output:
	// From p1 From p2 123
}

func TestParallel(t *testing.T) {
	Parallel(f1, f2, f3, func(fromP1, fromP2 string, fromP3 int, err error) {
		if err != nil {
			t.Error("Got unexpeted error")
		}
		if fromP1 != "From p1" || fromP2 != "From p2" || fromP3 != 123 {
			t.Fail()
		}
	})
}

func TestParallelErr(t *testing.T) {
	Parallel(f1, fErr, f2, f3, func(fromP1, fromErr, fromP2 string, fromP3 int, err error) {
		if err == nil {
			t.Error("Got nil err")
		} else if err.Error() != "Error from fErr" {
			t.Error("Got incorrect error")
		}
	})
	Parallel(f1, f2, fErr2, f3, func(fromF1, fromF2, fromFErr2 string, fromF3 int, err error) {
		if err == nil {
			t.Error("Got nil err")
		} else if err.Error() != "Error2 from fErr2" {
			t.Error("Got incorrect error")
		}
	})
}

func TestParallelNumInPanic(t *testing.T) {
	defer func() {
		if r := recover(); r == nil {
			t.Error("Did not panic")
		}
	}()
	badParallelFunc := func(unexpectedArgIn int) (res string, err error) { return }
	Parallel(badParallelFunc, func(res string, err error) {})
}

func TestParallelTypeOutPanic(t *testing.T) {
	defer func() {
		r := recover()
		if r != "Parallel function number 0 returns a \"string\" but final function expects a \"int\"" {
			t.Error("Did not panic with the expected message")
		}
	}()
	badParallelOutputFun := func() (res string, err error) { return }
	Parallel(badParallelOutputFun, func(res int, err error) {})
}

func TestParallelFinalErrArgPanic(t *testing.T) {
	defer func() {
		if r := recover(); r != "Parallel final function's last argument type should be error but is int" {
			t.Error("Did not panic with the expected message")
		}
	}()

	Parallel(f1, f2, func(res1, res2 string, err int) {})
}

func TestParallelFinalFuncReturnsError(t *testing.T) {
	var err error
	err = Parallel(f1, f2, func(res1, res2 string, err error) {})
	assert(t, err == nil)
	err = Parallel(f1, fErr, func(res1, res2 string, err error) {})
	assert(t, err != nil)
	err = Parallel(f1, f2, func(res1, res2 string, err error) error { return nil })
	assert(t, err == nil)
	err = Parallel(f1, fErr, func(res1, res2 string, err error) error { return errors.New("A new error") })
	assert(t, err != nil)
	assert(t, err.Error() == "A new error")
	err = Parallel(f1, f2, func(res1, res2 string, err error) error { return nil })
	assert(t, err == nil)
}

func noErr() error     { return nil }
func blurghErr() error { return errors.New("Blurgh") }

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

func fErr2() (res string, err error) {
	err = errors.New("Error2 from fErr2")
	return
}

func fErr() (res string, err error) {
	err = errors.New("Error from fErr")
	return
}
func f3() (int, error) {
	return 123, nil
}
func f1() (string, error) {
	return "From p1", nil
}
func f2() (string, error) {
	return "From p2", nil
}
