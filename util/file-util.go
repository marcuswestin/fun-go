package util

import (
	"os"

	"github.com/marcuswestin/fun-go/errs"
)

func Open(path string) (file *os.File, err errs.Err) {
	file, stdErr := os.Open(path)
	if stdErr != nil {
		err = errs.Wrap(stdErr, errs.Info{"Path": path})
		return
	}
	return
}
