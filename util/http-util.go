package util

import (
	"io"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/marcuswestin/fun-go/errs"
)

func HTTPGet(url string) (statusCode int, body string, err errs.Err) {
	return do("GET", url, "", nil)
}

func HTTPPostJSON(url string, jsonPayload interface{}) (statusCode int, body string, err errs.Err) {
	jsonReader, err := JSONReader(jsonPayload)
	if err != nil {
		return
	}
	return do("POST", url, "application/json", jsonReader)
}

func HTTPPostString(url string, str string) (statusCode int, body string, err errs.Err) {
	reader := strings.NewReader(str)
	return do("POST", url, "text/plain", reader)
}

func do(method, url, contentType string, bodyReader io.Reader) (statusCode int, responseBody string, err errs.Err) {
	req, stdErr := http.NewRequest("GET", url, bodyReader)
	if stdErr != nil {
		err = errs.Wrap(stdErr, errs.Info{"URL": url})
		return
	}
	if contentType != "" {
		req.Header.Set("Content-Type", contentType)
	}
	req.Close = true
	req.Header.Set("Connection", "close")

	res, stdErr := http.DefaultClient.Do(req)
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
	responseBody = string(bodyBytes)
	return
}
