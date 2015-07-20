package util

import (
	"encoding/json"
	"io"

	"github.com/marcuswestin/fun-go/errs"
)

func JSON(v interface{}) (string, errs.Err) {
	bytes, err := JSONBytes(v)
	return string(bytes), err
}
func JSONBytes(v interface{}) ([]byte, errs.Err) {
	bytes, stdErr := json.Marshal(v)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{}, "Could not convert to JSON")
	}
	return bytes, nil
}
func ParseJSON(jsonStr string, v interface{}) errs.Err {
	return ParseJSONBytes([]byte(jsonStr), v)
}
func ParseJSONBytes(jsonBytes []byte, v interface{}) errs.Err {
	stdErr := json.Unmarshal(jsonBytes, v)
	if stdErr != nil {
		return errs.Wrap(stdErr, nil, "Could not parse JSON")
	}
	return nil
}

func DecodeJSON(reader io.Reader, v interface{}) errs.Err {
	stdErr := json.NewDecoder(reader).Decode(v)
	if stdErr != nil {
		return errs.Wrap(stdErr, errs.Info{})
	}
	return nil
}
