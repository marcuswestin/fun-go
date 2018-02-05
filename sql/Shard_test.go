package sql

import (
	"asapp/t/errs"
	"errors"
	"testing"

	funGoErrs "github.com/marcuswestin/fun-go/errs"
	"github.com/stretchr/testify/assert"
)

type mockCircuitBreaker struct {
	numCalled int
}

func (dbcb *mockCircuitBreaker) CircuitBreakerHandler() (func(), error) {
	dbcb.numCalled++
	return func() {}, nil
}

type mockShard struct {
	BeginEndHandler func() (func(), error)
	MetricsHandler  func(string, string) func()
}

func (s *mockShard) Transact(txFun TxFunc) error {
	if s.BeginEndHandler != nil {
		doneFunc, err := s.BeginEndHandler()
		if err != nil {
			return err
		}
		defer doneFunc()
	}
	err := txFun(&Shard{MetricsHandler: s.MetricsHandler})
	if err != nil {
		//simulate successful rollback swallowing the error
		return nil
	}
	return nil
}

func (s *mockShard) TransactWithPropagatedErrors(txFun TxFunc) error {
	var err errs.Err
	var txnResult = s.Transact(TxFunc(func(shard *Shard) funGoErrs.Err {
		err = txFun(shard)
		return err
	}))
	if txnResult != nil {
		return txnResult
	}
	return err
}
func TestCircuitBreakerCalled(t *testing.T) {
	dbcb := mockCircuitBreaker{numCalled: 0}
	s := Shard{BeginEndHandler: dbcb.CircuitBreakerHandler}
	assert.Panics(t, func() { s.Query("test query") })
	assert.Exactly(t, 1, dbcb.numCalled)
	assert.Panics(t, func() { s.Exec("test exec") })
	assert.Exactly(t, 2, dbcb.numCalled)
	m := &mockShard{BeginEndHandler: dbcb.CircuitBreakerHandler}
	tx := func(shard *Shard) (err funGoErrs.Err) {
		assert.Panics(t, func() { shard.Exec("test exec") })
		assert.Panics(t, func() { shard.Query("test query") })
		assert.Panics(t, func() { shard.Exec("another test exec") })
		return nil
	}
	m.Transact(tx)
	assert.Exactly(t, 3, dbcb.numCalled)
}
func TestCircuitBreakerNoHandler(t *testing.T) {
	dbcb := mockCircuitBreaker{numCalled: 0}
	s := &Shard{BeginEndHandler: nil}
	assert.Panics(t, func() { s.Query("test query") })
	assert.Exactly(t, 0, dbcb.numCalled)
}

type mockMetricsCollector struct {
	numCalled int
}

func (hist *mockMetricsCollector) HistogramHandler(string, string) func() {
	hist.numCalled++
	return nil
}
func TestHistogramNoHandler(t *testing.T) {
	hist := mockMetricsCollector{numCalled: 0}
	s := &Shard{MetricsHandler: nil}
	assert.Panics(t, func() { s.Query("test query") })
	assert.Exactly(t, 0, hist.numCalled)
}
func TestHistogramCalled(t *testing.T) {
	hist := mockMetricsCollector{numCalled: 0}
	s := &Shard{MetricsHandler: hist.HistogramHandler}
	assert.Panics(t, func() { s.Query("test query") })
	assert.Exactly(t, 1, hist.numCalled)
	assert.Panics(t, func() { s.Exec("test exec") })
	assert.Exactly(t, 2, hist.numCalled)
	m := &mockShard{MetricsHandler: hist.HistogramHandler}
	tx := func(shard *Shard) (err funGoErrs.Err) {
		assert.Panics(t, func() { shard.Exec("test exec") })
		assert.Panics(t, func() { shard.Query("test query") })
		assert.Panics(t, func() { shard.Exec("another test exec") })
		return nil
	}
	m.Transact(tx)
	assert.Exactly(t, 5, hist.numCalled)
}

func TestNoErrorPropagated(testing *testing.T) {
	m := &mockShard{}
	tx := func(shard *Shard) (err funGoErrs.Err) {
		stdErr := errors.New("test error")
		return errs.Wrap(stdErr)
	}
	assert.NoError(testing, m.Transact(tx))
}

func TestErrorPropagated(testing *testing.T) {
	m := &mockShard{}
	tx := func(shard *Shard) (err funGoErrs.Err) {
		stdErr := errors.New("test error")
		return errs.Wrap(stdErr)
	}
	assert.Errorf(testing, m.TransactWithPropagatedErrors(tx), "test error")
}
