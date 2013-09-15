package fun

type parallelResult struct {
	index int
	value interface{}
}

type ParallelFunc func() (result interface{}, err error)

func Parallel(funs ...ParallelFunc) ([]interface{}, error) {
	results := make([]interface{}, len(funs))
	errChan := make(chan error)
	resChan := make(chan parallelResult)

	// Dispatch executions
	for i, fun := range funs {
		i := i
		fun := fun
		go func() {
			res, err := fun()
			if err != nil {
				errChan <- err
			} else {
				resChan <- parallelResult{index: i, value: res}
			}
		}()
	}

	// Collect results
	for i := 0; i < len(funs); i++ {
		select {
		case err := <-errChan:
			return nil, err
		case res := <-resChan:
			results[res.index] = res.value
		}
	}

	return results, nil
}
