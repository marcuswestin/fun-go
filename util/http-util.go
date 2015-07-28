package util

import (
	"net/http"
	"strings"

	"github.com/marcuswestin/fun-go/errs"
)

func HTTPGet(url string) (*http.Response, errs.Err) {
	res, stdErr := http.Get(url)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{"URL": url})
	}
	return res, nil
}

func HTTPPostJSON(url string, jsonPayload interface{}) (*http.Response, errs.Err) {
	jsonReader, err := JSONReader(jsonPayload)
	if err != nil {
		return nil, err
	}
	res, stdErr := http.Post(url, "application/json", jsonReader)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{"URL": url, "Payload": jsonPayload})
	}
	return res, nil
}

func HTTPPostString(url string, str string) (*http.Response, errs.Err) {
	reader := strings.NewReader(str)
	res, stdErr := http.Post(url, "text/plain", reader)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{"URL": url, "String": str})
	}
	return res, nil
}
