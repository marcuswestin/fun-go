package fun

import (
	"reflect"
)

type parallelResult struct {
	index        int
	returnValues []reflect.Value
}

var nilerror = error(nil)

func Parallel(args ...interface{}) {
	l := len(args) - 1
	funs := args[:l]
	done := args[l]

	results := make([]reflect.Value, len(funs)+1)
	errorIndex := len(results) - 1
	resChan := make(chan parallelResult)
	doneVal := reflect.ValueOf(done)

	// Dispatch executions
	for i, fun := range funs {
		i := i
		fun := reflect.ValueOf(fun)
		go func() {
			returnValues := fun.Call(nil)
			resChan <- parallelResult{index: i, returnValues: returnValues}
		}()
	}

	errSet := false

	// Collect results
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
		results[errorIndex] = reflect.ValueOf(&nilerror).Elem()
	}
	doneVal.Call(results)
}
