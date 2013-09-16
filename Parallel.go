package fun

import (
	"fmt"
	"reflect"
)

func Parallel(args ...interface{}) error {
	l := len(args) - 1
	funs := args[:l]
	done := args[l]
	doneVal := reflect.ValueOf(done)
	doneTyp := doneVal.Type()
	errorIndex := len(funs)
	results := make([]reflect.Value, len(funs)+1)
	resChan := make(chan parallelResult)

	// Check types
	if doneTyp.NumIn() != len(funs)+1 {
		panic(fmt.Sprintf(finalFuncNumArgsMsg, len(funs)+1))
	}
	if !doneTyp.In(errorIndex).Implements(errorInterface) {
		panic(fmt.Sprint(finalFuncErrArgMsg, doneTyp.In(errorIndex)))
	}
	for funI, fun := range funs {
		funTyp := reflect.TypeOf(fun)
		if funTyp.NumIn() > 0 {
			panic(fmt.Sprintf(argFuncNoArgsMsg, funI+1, reflect.ValueOf(funTyp).Interface()))
		}
		if funTyp.NumOut() != 2 {
			panic(fmt.Sprintf(argFuncNumReturnMsg, funI, funTyp.NumOut()))
		}
		if funTyp.Out(0) != doneTyp.In(funI) {
			panic(fmt.Sprintf(argFuncDoneFuncTypeMismatch, funI, funTyp.Out(0), doneTyp.In(funI)))
		}
		if !funTyp.Out(1).Implements(errorInterface) {
			panic(fmt.Sprintf(argFuncErrReturnMsg, funI, funTyp.Out(1)))
		}
	}

	// Dispatch executions
	for i, fun := range funs {
		i := i
		fun := reflect.ValueOf(fun)
		go func() {
			returns := fun.Call(nil)
			resChan <- parallelResult{index: i, val: returns[0], err: returns[1]}
		}()
	}

	// Collect results
	for i := 0; i < len(funs); i++ {
		res := <-resChan

		// There was an error
		if !res.err.IsNil() {
			for funI, fun := range funs {
				results[funI] = reflect.Zero(reflect.ValueOf(fun).Type().Out(0))
			}
			results[errorIndex] = res.err
			doneVal.Call(results)
			return res.err.Interface().(error)
		}

		results[res.index] = res.val
	}

	results[errorIndex] = reflect.ValueOf(&nilError).Elem()
	doneVal.Call(results)

	return nil
}

type parallelResult struct {
	index int
	val   reflect.Value
	err   reflect.Value
}

var nilError = error(nil)
var errorInterface = reflect.TypeOf(func(error) {}).In(0)

const finalFuncErrArgMsg = "Parallel final function's last argument type should be error but is "
const finalFuncNumArgsMsg = "Parallel final function should take %d arguments"
const argFuncNoArgsMsg = "Parallel functions should not take any arguments\n(offending function is number %d with signature %q)"
const argFuncNumReturnMsg = "Parallel function number %d should return two values (returns %d)"
const argFuncDoneFuncTypeMismatch = "Parallel function number %d returns a %q but final function expects a %q"
const argFuncErrReturnMsg = "Parallel function number %d should return an error as second return value (returns %q)"
