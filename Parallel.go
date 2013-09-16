package fun

import (
	"fmt"
	"reflect"
)

type parallelResult struct {
	index        int
	returnValues []reflect.Value
}

var nilError = error(nil)
var errorInterface = reflect.TypeOf(func(error) {}).In(0)

func Parallel(args ...interface{}) {
	l := len(args) - 1
	funs := args[:l]
	done := args[l]
	doneVal := reflect.ValueOf(done)
	doneTyp := doneVal.Type()

	for funI, fun := range funs {
		funTyp := reflect.TypeOf(fun)
		if funTyp.NumIn() > 0 {
			panic(fmt.Sprintf("Parallel functions should not take any arguments\n(offending function is number %d with signature %q)", funI+1, reflect.ValueOf(funTyp).Interface()))
		}
		for outI := 0; outI < funTyp.NumOut(); outI++ {
			if funTyp.Out(outI).Implements(errorInterface) { // Error outputs are always OK
				continue
			}
			outputKind := funTyp.Out(outI).Kind()
			if outputKind != doneTyp.In(funI).Kind() {
				panic(fmt.Sprintf("Parallel function number %d returns a different value kind than the reciving function accepts", funI+1))
			}
		}
	}

	results := make([]reflect.Value, len(funs)+1)
	errorIndex := len(results) - 1
	resChan := make(chan parallelResult)

	// Dispatch executions
	for i, fun := range funs {
		i := i
		fun := reflect.ValueOf(fun)
		go func() {
			returnValues := fun.Call(nil)
			resChan <- parallelResult{index: i, returnValues: returnValues}
		}()
	}

	// Collect results
	errSet := false
	for i := 0; i < len(funs); i++ {
		res := <-resChan
		for _, returnValue := range res.returnValues {

			if returnValue.Kind() != reflect.String && returnValue.Kind() != reflect.Int && returnValue.IsNil() {
				continue
			}

			err, isErrorType := returnValue.Interface().(error)
			if isErrorType {
				if err != nil && !errSet {
					results[errorIndex] = reflect.ValueOf(err)
					errSet = true
				}
			} else {
				results[res.index] = returnValue
			}
		}
	}

	if !errSet {
		results[errorIndex] = reflect.ValueOf(&nilError).Elem()
	}

	doneVal.Call(results)
}
