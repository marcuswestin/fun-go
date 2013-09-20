package sql

import (
	"database/sql"
	"encoding/binary"
	"errors"
	"fmt"
	"reflect"
)

func SelectInt(conn *sql.DB, query string, args ...interface{}) (num int, found bool, err error) {
	found, err = queryOne(conn, query, args, &num)
	return
}

func SelectString(conn *sql.DB, query string, args ...interface{}) (str string, found bool, err error) {
	found, err = queryOne(conn, query, args, &str)
	return
}

func SelectUInt(conn *sql.DB, query string, args ...interface{}) (num uint, found bool, err error) {
	found, err = queryOne(conn, query, args, &num)
	return
}

func queryOne(conn *sql.DB, query string, args []interface{}, out interface{}) (found bool, err error) {
	rows, err := conn.Query(query, args...)
	if err != nil {
		return
	}

	if rows.Next() {
		found = true
		err = rows.Scan(out)
		if err != nil {
			return
		}
	}

	if rows.Next() {
		err = errors.New("Query returned too many columns")
		return
	}

	return
}

type TransactFunc func(conn *sql.DB) error

func Transact(conn *sql.DB, f TransactFunc) (err error) {
	_, err = conn.Exec("START TRANSACTION")
	if err != nil {
		return
	}

	err = f(conn)
	if err != nil {
		_, rollbackError := conn.Exec("ROLLBACK")
		if rollbackError != nil {
			panic("Could not rollback transaction. TransactionFunc error: " + err.Error() + ". Rollback error:" + rollbackError.Error())
		}

	} else {
		_, err = conn.Exec("COMMIT")
	}

	return
}

func UpdateOne(conn *sql.DB, query string, args ...interface{}) error {
	res, err := conn.Exec(query, args...)
	if err != nil {
		return err
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected != 1 {
		return errors.New(fmt.Sprintf("UpdateOne affected %d rows", affected))
	}

	return nil
}

func InsertIgnoreId(conn *sql.DB, query string, args ...interface{}) (err error) {
	_, err = Insert(conn, query, args...)
	return
}

func Insert(conn *sql.DB, query string, args ...interface{}) (int64, error) {
	res, err := conn.Exec(query, args...)
	if err != nil {
		return 0, err
	}
	return res.LastInsertId()
}

func Select(conn *sql.DB, output interface{}, sql string, args ...interface{}) error {
	// Check types
	var outputPtr = reflect.ValueOf(output)
	if outputPtr.Kind() != reflect.Ptr {
		return errors.New("fun/sql.Select: expects a pointer to a slice of items")
	}
	var outputReflection = reflect.Indirect(outputPtr)
	if outputReflection.Kind() != reflect.Slice {
		return errors.New("fun/sql.Select: expects items to be a slice")
	}
	if outputReflection.Len() != 0 {
		return errors.New("fun/sql.Select: expects items to be empty")
	}
	outputItemType := outputReflection.Type().Elem().Elem()
	if outputItemType.Kind() != reflect.Struct {
		return errors.New("fun/sql.Select: expects items to be a slice of structs")
	}

	// Query DB
	var rows, err = conn.Query(sql, args...)
	if err != nil {
		return err
	}

	// Reflect onto structs
	columns, err := rows.Columns()
	if err != nil {
		return err
	}
	structType := outputReflection.Type()
	for rows.Next() {
		structPtrVal, err := structFromRow(structType, columns, rows)
		if err != nil {
			return err
		}

		outputReflection.Set(reflect.Append(outputReflection, structPtrVal))
	}
	return nil
}

const selectOneTypeError = "fun/sql.SelectOne: expects a **struct, e.g var person *Person; c.SelectOne(&person, sql)"

func SelectOne(conn *sql.DB, output interface{}, query string, args ...interface{}) error {
	// Check types
	var outputReflectionPtr = reflect.ValueOf(output)
	if outputReflectionPtr.Kind() != reflect.Ptr {
		return errors.New(selectOneTypeError)
	}
	var outputReflection = outputReflectionPtr.Elem()
	if outputReflection.Kind() != reflect.Ptr {
		return errors.New(selectOneTypeError)
	}

	// Query DB
	var rows, err = conn.Query(query, args...)
	if err != nil {
		return err
	}

	// Reflect onto struct
	columns, err := rows.Columns()
	if err != nil {
		return err
	}
	if !rows.Next() {
		return errors.New("fun/sql.SelectOne: got none")
	}
	structType := outputReflection.Type()
	structPtrVal, err := structFromRow(structType, columns, rows)
	if err != nil {
		return err
	}
	outputReflection.Set(structPtrVal)

	if rows.Next() {
		return errors.New("fun/sql.SelectOne: got multiple rows")
	}

	return nil
}

func structFromRow(structType reflect.Type, columns []string, rows *sql.Rows) (structPtrVal reflect.Value, err error) {
	structPtrVal = reflect.New(structType.Elem())

	vals := make([]interface{}, len(columns))
	for i, _ := range columns {
		vals[i] = &sql.RawBytes{}
		// vals[i] = &[]byte{}
	}
	err = rows.Scan(vals...)
	if err != nil {
		return
	}

	outputItemStructVal := structPtrVal.Elem()
	for i, column := range columns {
		bytes := []byte(*vals[i].(*sql.RawBytes))
		if bytes == nil {
			continue // Leave struct field empty
		}
		var outputItemField = outputItemStructVal.FieldByName(column)
		switch outputItemField.Kind() {
		case reflect.String:
			outputItemField.SetString(string(bytes))
		case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
			val, num := binary.Uvarint(bytes) // Alt: strconv.ParseUint(string(bytes), 10, 64)
			if num <= 0 {
				err = errors.New("fun/sql: Could not parse uint from bytes")
				return
			}
			outputItemField.SetUint(reflect.ValueOf(val).Uint())
		case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
			val, num := binary.Varint(bytes) // Alt: strconv.ParseInt(string(bytes), 10, 64)
			if num <= 0 {
				err = errors.New("fun/sql: Could not parse uint from bytes")
				return
			}
			outputItemField.SetInt(reflect.ValueOf(val).Int())
		default:
			err = errors.New("fun/sql: Bad row value for column: " + column)
			return
		}
	}
	return
}
