package util

import (
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/marcuswestin/fun-go/errs"
)

func HTTPGet(url string) (statusCode int, body string, err errs.Err) {
	res, stdErr := http.Get(url)
	return wrapHandleRes(url, res, stdErr)
}

func HTTPPostJSON(url string, jsonPayload interface{}) (statusCode int, body string, err errs.Err) {
	jsonReader, err := JSONReader(jsonPayload)
	if err != nil {
		return
	}
	res, stdErr := http.Post(url, "application/json", jsonReader)
	return wrapHandleRes(url, res, stdErr)
}

func HTTPPostString(url string, str string) (statusCode int, body string, err errs.Err) {
	reader := strings.NewReader(str)
	res, stdErr := http.Post(url, "text/plain", reader)
	return wrapHandleRes(url, res, stdErr)
}

func wrapHandleRes(url string, res *http.Response, stdErr error) (statusCode int, body string, err errs.Err) {
	if stdErr != nil {
		err = errs.Wrap(stdErr, errs.Info{"URL": url})
		return
	}
	defer res.Body.Close()

	statusCode = res.StatusCode
	bodyBytes, stdErr := ioutil.ReadAll(res.Body)
	if stdErr != nil {
		err = errs.Wrap(stdErr, errs.Info{"URL": url})
		return
	}
	body = string(bodyBytes)
	return
}
