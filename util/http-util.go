package util

import (
	"net/http"

	"github.com/marcuswestin/fun-go/errs"
)

func HTTPGet(url string) (*http.Response, errs.Err) {
	res, stdErr := http.Get(url)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{"URL": url})
	}
	return res, nil
}
