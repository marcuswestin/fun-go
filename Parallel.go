package fun

import (
	"fmt"
	"reflect"
)

type parallel2Result struct {
	i   int
	val interface{}
	err error
}

func Parallel2(funs ...interface{}) ([]interface{}, error) {
	resChan := make(chan parallel2Result)
	results := make([]interface{}, len(funs))
	// Dispatch functions
	for i, fun := range funs {
		go func(i int, fun interface{}) {
			res := reflect.ValueOf(fun).Call(nil)
			val, _ := res[0].Interface().(interface{})
			err, _ := res[1].Interface().(error)
			resChan <- parallel2Result{i: i, val: val, err: err}
		}(i, fun)
	}
	// Collect results
	for i := 0; i < len(funs); i++ {
		res := <-resChan
		if res.err != nil {
			return nil, res.err
		}
		results[res.i] = res.val
	}
	return results, nil
}

func Parallel(args ...interface{}) error {
	if reflect.TypeOf(args[0]).NumOut() == 2 {
		funs := args[:len(args)-1]
		return parallelWithDone(funs, Last(args))
	} else {
		return parallelWithoutDone(args)
	}
}

func parallelWithoutDone(funs []interface{}) error {
	resChan := make(chan reflect.Value)

	for _, fun := range funs {
		fun := reflect.ValueOf(fun)
		go func() {
			resChan <- fun.Call(nil)[0]
		}()
	}

	for i := 0; i < len(funs); i++ {
		res := <-resChan

		// There was an error
		if !res.IsNil() {
			return res.Interface().(error)
		}
	}

	return nil
}

func parallelWithDone(funs []interface{}, done interface{}) error {
	doneVal := reflect.ValueOf(done)
	doneTyp := doneVal.Type()
	errorIndex := len(funs)
	results := make([]reflect.Value, len(funs)+1)
	resChan := make(chan parallelResult)
	doneReturnsError := false

	// Check types
	if doneTyp.NumIn() != len(funs)+1 {
		panic(fmt.Sprintf(finalFuncNumArgsMsg, len(funs)+1))
	}
	if !doneTyp.In(errorIndex).Implements(errorInterface) {
		panic(fmt.Sprint(finalFuncErrArgMsg, doneTyp.In(errorIndex)))
	}
	if doneTyp.NumOut() > 1 {
		panic(fmt.Sprint(finalFuncReturnCountMsg, doneTyp.NumOut()))
	}
	if doneTyp.NumOut() == 1 {
		if !doneTyp.Out(0).Implements(errorInterface) {
			panic(fmt.Sprint(finalFuncReturnWrongTypeMsg, doneTyp.Out(0)))
		}
		doneReturnsError = true
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
			doneRes := doneVal.Call(results)
			if !doneReturnsError {
				return res.err.Interface().(error)
			}
			return doneRes[0].Interface().(error)
		}

		results[res.index] = res.val
	}

	results[errorIndex] = reflect.ValueOf(&nilError).Elem()
	doneRes := doneVal.Call(results)
	if !doneReturnsError {
		return nil
	}
	if doneRes[0].IsNil() {
		return nil
	}
	return doneRes[0].Interface().(error)
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
const finalFuncReturnCountMsg = "Parallel final function should return nothing or one error (returns %d values)"
const finalFuncReturnWrongTypeMsg = "Parallel final function return value must be an error (is %q)"
