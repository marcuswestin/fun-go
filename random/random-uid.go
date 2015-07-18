package random

import (
	"crypto/rand"
	"encoding/base64"
	"errors"
	"io"
)

func Uid(numChars int) (uid string, err error) {
	if numChars%4 != 0 {
		err = errors.New("uid length must be a multiple of 4")
		return
	}
	buf := make([]byte, numChars)
	_, err = io.ReadFull(rand.Reader, buf)
	if err != nil {
		return
	}

	uid = base64.URLEncoding.EncodeToString(buf)

	return
}
