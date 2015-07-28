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
	UserMessage() string
	SetUserMessage(userMessage string)
	InternalInfo() Info
	LogString() string
}

type Info map[string]interface{}

var (
	DefaultUserMessage = "Oops! Something went wrong. Please try again."
)

func Wrap(stdErr error, internalInfo Info, userMessageStrs ...interface{}) Err {
	return newErr(stdErr, internalInfo, userMessageStrs)
}
func New(internalInfo Info, userMessageStrs ...interface{}) Err {
	return newErr(nil, internalInfo, userMessageStrs)
}
func UserError(userMessage interface{}, infos ...Info) Err { // Variable infos to allow no-info case easily
	if len(infos) == 0 {
		return newErr(nil, nil, []interface{}{userMessage})
	} else if len(infos) == 1 {
		return newErr(nil, infos[0], []interface{}{userMessage})
	} else {
		panic("UserError expected at most one info")
	}
}

func newErr(stdErr error, internalInfo Info, userMessageStrs []interface{}) Err {
	userMessage := fmt.Sprint(userMessageStrs...)
	if userMessage == "" {
		userMessage = DefaultUserMessage
	}
	return &err{debug.Stack(), time.Now(), stdErr, internalInfo, userMessage}
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
func (e *err) LogString() string {
	err := "nil"
	if e.stdErr != nil {
		err = e.stdErr.Error()
	}
	return fmt.Sprint("Error | UserMessage: ", e.userMessage, " | StandardError: "+err+" | Stack: ", string(e.stack), " | tInternalInfo:[", e.internalInfo, "Time:", e.time)
}

func (e *err) String() string { return e.LogString() }
