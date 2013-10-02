package fun

import (
	cryptoRand "crypto/rand"
	"encoding/base64"
	"errors"
	"io"
	"math"
	mathRand "math/rand"
	"strconv"
	"time"
)

func init() {
	mathRand.Seed(time.Now().UnixNano())
}

// Returns a random int in the range [min, lessThan)
func RandomBetween(min, lessThan int) int {
	return mathRand.Intn(lessThan-min) + min
}

// Returns a random number with numDigits digits
func RandomDigits(numDigits int) int {
	min := int(math.Pow10(numDigits - 1))
	lessThan := int(math.Pow10(numDigits))
	return RandomBetween(min, lessThan)
}

func RandomDigitString(numDigits int) string {
	return strconv.Itoa(RandomDigits(numDigits))
}

func MakeUid(numChars int) (uid string, err error) {
	if numChars%4 != 0 {
		err = errors.New("uid length must be a multiple of 4")
		return
	}

	buf := make([]byte, numChars)
	_, err = io.ReadFull(cryptoRand.Reader, buf)
	if err != nil {
		return
	}

	uid = base64.URLEncoding.EncodeToString(buf)

	return
}
