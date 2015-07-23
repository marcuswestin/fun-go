package random

import (
	"crypto/rand"
	"encoding/base64"
	"io"

	"github.com/marcuswestin/fun-go/errs"
)

func Uid(numChars int) (uid string, err errs.Err) {
	if numChars%4 != 0 {
		err = errs.New(nil, "uid length must be a multiple of 4")
		return
	}
	buf := make([]byte, numChars)
	_, stdErr := io.ReadFull(rand.Reader, buf)
	if stdErr != nil {
		err = errs.Wrap(stdErr, nil)
		return
	}

	uid = base64.URLEncoding.EncodeToString(buf)
	return
}
