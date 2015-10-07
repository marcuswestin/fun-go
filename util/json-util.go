package util

import (
	"bytes"
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
func JSONBytesIndent(v interface{}, prefix, indent string) ([]byte, errs.Err) {
	jsonBytes, stdErr := json.MarshalIndent(v, prefix, indent)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{})
	}
	return jsonBytes, nil
}
func JSONMustPrettyPrint(v interface{}) string {
	bytes, err := JSONBytesIndent(v, "", "\t")
	if err != nil {
		panic(err)
	}
	return string(bytes)
}
func JSONReader(v interface{}) (reader io.Reader, err errs.Err) {
	jsonBytes, err := JSONBytes(v)
	if err != nil {
		return
	}
	return bytes.NewBuffer(jsonBytes), nil
}
func ParseJSON(jsonStr string, v interface{}) errs.Err {
	return ParseJSONBytes([]byte(jsonStr), v)
}
func ParseJSONBytes(jsonBytes []byte, v interface{}) errs.Err {
	stdErr := json.Unmarshal(jsonBytes, v)
	if stdErr != nil {
		return errs.Wrap(stdErr, errs.Info{"JSON": string(jsonBytes)}, "Could not parse JSON")
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
