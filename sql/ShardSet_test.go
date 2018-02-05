package sql

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewShardSetWithBeginEndHandler(t *testing.T) {
	f := func() (func(), error) {
		return func() {}, nil
	}
	n := NewShardSet("test", "test", "test", 9999, "test", 9999, 9999, 9999, WithBeginEndHandler(f))
	assert.NotEmpty(t, n)
	assert.NotNil(t, n.beginEndHandler)
}
func TestNewShardSetWithNoBeginEndHandler(t *testing.T) {
	n := NewShardSet("test", "test", "test", 9999, "test", 9999, 9999, 9999)
	assert.NotEmpty(t, n)
	assert.Nil(t, n.beginEndHandler)
}
func TestNewShardSetWithMetricsHandler(t *testing.T) {
	f := func(string, string) func() {
		return func() {}
	}
	n := NewShardSet("test", "test", "test", 9999, "test", 9999, 9999, 9999, WithMetricsHandler(f))
	assert.NotEmpty(t, n)
	assert.NotNil(t, n.metricsHandler)
}
func TestNewShardSetWithBothHandlers(t *testing.T) {
	metricsHandler := func(string, string) func() {
		return func() {}
	}
	beginEndHandler := func() (func(), error) {
		return func() {}, nil
	}
	n := NewShardSet("test", "test", "test", 9999, "test", 9999, 9999, 9999, WithBeginEndHandler(beginEndHandler), WithMetricsHandler(metricsHandler))
	assert.NotEmpty(t, n)
	assert.NotNil(t, n.beginEndHandler)
	assert.NotNil(t, n.metricsHandler)
}
