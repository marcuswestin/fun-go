package errs

import (
	"fmt"
	"runtime/debug"
	"time"
)

type Err interface {
	Stack() []byte
	Time() time.Time
	StandardError() error
	StandardErrorMessage() string
	UserMessage() string
	SetUserMessage(userMessage string)
	InternalInfo() Info
	LogString() string
}

type Info map[string]interface{}
type Opts struct {
	OmitStack bool
}

var (
	DefaultUserMessage = "Oops! Something went wrong. Please try again."
	DefaultOpts        = Opts{
		OmitStack: false,
	}
)

func Wrap(stdErr error, internalInfo Info, userMessage ...interface{}) Err {
	if stdErr == nil {
		return nil
	}
	return WrapWithOpts(stdErr, internalInfo, DefaultOpts, userMessage...)
}
func New(internalInfo Info, userMessage ...interface{}) Err {
	return NewWithOpts(internalInfo, DefaultOpts, userMessage...)
}
func WrapWithOpts(stdErr error, internalInfo Info, opts Opts, userMessage ...interface{}) Err {
	if stdErr == nil {
		return nil
	}
	return newErr(stdErr, internalInfo, opts, userMessage)
}
func NewWithOpts(internalInfo Info, opts Opts, userMessage ...interface{}) Err {
	return newErr(nil, internalInfo, opts, userMessage)
}

func newErr(stdErr error, internalInfo Info, opts Opts, userMessageParts []interface{}) Err {
	userMessage := fmt.Sprint(userMessageParts...)
	if userMessage == "" {
		userMessage = DefaultUserMessage
	}
	var stack []byte
	if !opts.OmitStack {
		stack = debug.Stack()
	}
	if internalInfo == nil {
		internalInfo = Info{}
	}
	return &err{stack, time.Now(), stdErr, internalInfo, userMessage}
}

type err struct {
	stack        []byte
	time         time.Time
	stdErr       error
	internalInfo Info
	userMessage  string
}

func (e *err) Stack() []byte             { return e.stack }
func (e *err) Time() time.Time           { return e.time }
func (e *err) StandardError() error      { return e.stdErr }
func (e *err) UserMessage() string       { return e.userMessage }
func (e *err) SetUserMessage(msg string) { e.userMessage = msg }
func (e *err) InternalInfo() Info        { return e.internalInfo }
func (e *err) StandardErrorMessage() string {
	if e == nil {
		return ""
	}
	if e.stdErr == nil {
		return ""
	}
	return e.stdErr.Error()
}
func (e *err) LogString() string {
	return fmt.Sprint("Error | UserMessage: ", e.userMessage, " | StandardError: "+e.StandardErrorMessage()+" | Stack: ", string(e.stack), " | tInternalInfo:[", e.internalInfo, "Time:", e.time)
}

func (e *err) String() string { return e.LogString() }
