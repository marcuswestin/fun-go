package errs

import (
	"runtime/debug"
	"strings"
	"time"
)

type Err interface {
	Stack() []byte
	Time() time.Time
	StandardError() error
	UserMessage() string
	InternalMessage() string
	InternalInfo() Info
}

type Info map[string]interface{}

var (
	DefaultUserMessage     = "Oops! Something went wrong. Please try again."
	DefaultInternalMessage = "NO_INTERNAL_MESSAGE"
	DefaultInternalInfo    = Info(nil)
)

func Wrap(stdErr error, internalMessage string, internalInfo Info, userMessageStrs ...string) Err {
	return newErr(stdErr, internalInfo, internalMessage, userMessageStrs)
}
func New(internalMessage string, internalInfo Info, userMessageStrs ...string) Err {
	return newErr(nil, internalInfo, internalMessage, userMessageStrs)
}
func newErr(stdErr error, internalInfo Info, internalMessage string, userMessageStrs []string) Err {
	userMessage := strings.Join(userMessageStrs, " ")
	if userMessage == "" {
		userMessage = DefaultUserMessage
	}
	if internalMessage == "" {
		internalMessage = DefaultInternalMessage
	}
	if internalInfo == nil {
		internalInfo = DefaultInternalInfo
	}
	return &err{debug.Stack(), time.Now(), stdErr, internalInfo, internalMessage, userMessage}
}

type err struct {
	stack           []byte
	time            time.Time
	stdErr          error
	internalInfo    Info
	internalMessage string
	userMessage     string
}

func (e *err) Stack() []byte           { return e.stack }
func (e *err) Time() time.Time         { return e.time }
func (e *err) StandardError() error    { return e.stdErr }
func (e *err) UserMessage() string     { return e.userMessage }
func (e *err) InternalMessage() string { return e.internalMessage }
func (e *err) InternalInfo() Info      { return e.internalInfo }
