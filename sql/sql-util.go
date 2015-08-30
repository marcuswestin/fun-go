package sql

import (
	"fmt"
	"reflect"
	"strings"
)

func SelectAll(structVal interface{}) string {
	valType := reflect.TypeOf(structVal)
	numFields := valType.NumField()
	fields := make([]string, numFields)
	for i := 0; i < numFields; i++ {
		fields[i] = valType.Field(i).Name
	}
	fmt.Println("HERE", strings.Join(fields, ", "))
	return strings.Join(fields, ", ")
}
