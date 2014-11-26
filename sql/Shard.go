package sql

import (
	"database/sql"
	"errors"
	"fmt"
	"reflect"
	"strconv"
	"strings"
)

type shard struct {
	db *sql.DB
	shardConn
}

type sqlConn interface {
	Exec(query string, args ...interface{}) (sql.Result, error)
	Query(query string, args ...interface{}) (*sql.Rows, error)
}

type shardConn struct {
	sqlConn
}

func (s *shard) Autocommit(acFun TxFunc) (err error) {
	tx, err := s.db.Begin()
	if err != nil {
		return
	}

	return acFun(&shardConn{tx})
}

func (s *shard) Transact(txFun TxFunc) (err error) {
	tx, err := s.db.Begin()
	if err != nil {
		return
	}
	_, err = tx.Exec("START TRANSACTION")
	if err != nil {
		return
	}

	err = txFun(&shardConn{tx})
	if err != nil {
		rbErr := tx.Rollback()
		if rbErr != nil {
			return errors.New("Rollback error: " + rbErr.Error() + " Query error: " + err.Error())
		}

	} else {
		err = tx.Commit()
		if err != nil {
			return
		}
	}

	return
}

// Query with fixed args
func (s *shardConn) Query(query string, args ...interface{}) (rows *sql.Rows, err error) {
	fixArgs(args)
	rows, err = s.sqlConn.Query(query, args...)
	if err != nil {
		err = errors.New("sql.Query Error: " + err.Error() + ". Query: " + query + " Args: " + fmt.Sprint(args))
	}
	return
}

// Execute with fixed args
func (s *shardConn) Exec(query string, args ...interface{}) (res sql.Result, err error) {
	fixArgs(args)
	res, err = s.sqlConn.Exec(query, args...)
	if err != nil {
		err = errors.New("sql.Exec Error: " + err.Error() + ". Query: " + query + " Args: " + fmt.Sprint(args))
	}
	return
}

/*
Fix args by converting them to values of their underlying kind.
This avoids problems in database/sql with e.g custom string types.
Without fixArgs, the following code:

	type Foo string
	...
	pool.Query("SELECT * WHERE Foo=?", Foo("bar"))

would give you the error:

	sql: converting Exec argument #1's type: unsupported type Foo, a string
*/
func fixArgs(args []interface{}) {
	for i, arg := range args {
		vArg := reflect.ValueOf(arg)
		switch vArg.Kind() {
		case reflect.String:
			args[i] = vArg.String()
			if args[i] == "" {
				args[i] = nil
			}
		}
	}
}

func (s *shardConn) SelectInt(query string, args ...interface{}) (num int, err error) {
	found, err := s.queryOne(query, args, &num)
	if !found {
		err = errors.New("Query returned no rows")
	}
	return
}

func (s *shardConn) SelectString(query string, args ...interface{}) (str string, err error) {
	found, err := s.queryOne(query, args, &str)
	if !found {
		err = errors.New("Query returned no rows")
	}
	return
}

func (s *shardConn) SelectUint(query string, args ...interface{}) (num uint, err error) {
	found, err := s.queryOne(query, args, &num)
	if !found {
		err = errors.New("Query returned no rows")
	}
	return
}

func (s *shardConn) SelectIntForce(query string, args ...interface{}) (num int, err error) {
	found, err := s.queryOne(query, args, &num)
	if !found {
		panic("Query returned no rows")
	}
	return
}

func (s *shardConn) SelectStringForce(query string, args ...interface{}) (str string, err error) {
	found, err := s.queryOne(query, args, &str)
	if !found {
		panic("Query returned no rows")
	}
	return
}

func (s *shardConn) SelectUintForce(query string, args ...interface{}) (num uint, err error) {
	found, err := s.queryOne(query, args, &num)
	if !found {
		panic("Query returned no rows")
	}
	return
}

func (s *shardConn) SelectIntMaybe(query string, args ...interface{}) (num int, found bool, err error) {
	found, err = s.queryOne(query, args, &num)
	return
}

func (s *shardConn) SelectStringMaybe(query string, args ...interface{}) (str string, found bool, err error) {
	found, err = s.queryOne(query, args, &str)
	return
}

func (s *shardConn) SelectUintMaybe(query string, args ...interface{}) (num uint, found bool, err error) {
	found, err = s.queryOne(query, args, &num)
	return
}

func (s *shardConn) queryOne(query string, args []interface{}, out interface{}) (found bool, err error) {
	rows, err := s.Query(query, args...)
	if err != nil {
		return
	}
	defer rows.Close()

	if rows.Next() {
		err = rows.Scan(out)
		if err != nil {
			return
		}
		if rows.Next() {
			err = errors.New("Query returned too many rows")
			return
		}
		found = true
	} else {
		found = false
	}

	err = rows.Err()
	if err != nil {
		return
	}

	return
}

func (s *shardConn) UpdateOne(query string, args ...interface{}) (err error) {
	return s.UpdateNum(1, query, args...)
}

func (s *shardConn) UpdateNum(num int64, query string, args ...interface{}) (err error) {
	rowsAffected, err := s.Update(query, args...)
	if err != nil {
		return
	}
	if rowsAffected != num {
		return errors.New(fmt.Sprintf("UpdateOne affected %d rows. Query: %q Args: %q", rowsAffected, query, args))
	}
	return
}

func (s *shardConn) Update(query string, args ...interface{}) (rowsAffected int64, err error) {
	res, err := s.Exec(query, args...)
	if err != nil {
		return
	}

	rowsAffected, err = res.RowsAffected()
	return
}

func (s *shardConn) InsertIgnoreId(query string, args ...interface{}) (err error) {
	_, err = s.Insert(query, args...)
	return
}

func (s *shardConn) InsertIgnoreDuplicates(query string, args ...interface{}) (err error) {
	_, err = s.Insert(query, args...)
	if err != nil && strings.Contains(err.Error(), "Duplicate entry") {
		err = nil
	}
	return
}

func (s *shardConn) Insert(query string, args ...interface{}) (id int64, err error) {
	res, err := s.Exec(query, args...)
	if err != nil {
		return
	}
	id, err = res.LastInsertId()
	return
}

func (s *shardConn) Select(output interface{}, sql string, args ...interface{}) error {
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
	var rows, err = s.Query(sql, args...)
	if err != nil {
		return err
	}
	defer rows.Close()

	// Reflect onto structs
	columns, err := rows.Columns()
	if err != nil {
		return err
	}

	structType := outputReflection.Type().Elem()
	for rows.Next() {
		structPtrVal := reflect.New(structType.Elem())
		outputItemStructVal := structPtrVal.Elem()
		err = structFromRow(outputItemStructVal, columns, rows)
		if err != nil {
			return err
		}

		outputReflection.Set(reflect.Append(outputReflection, structPtrVal))
	}

	err = rows.Err()
	if err != nil {
		return err
	}

	return nil
}

const scanOneTypeError = "fun/sql.SelectOne: expects a **struct, e.g var person *Person; c.SelectOne(&person, sql)"

func (s *shardConn) SelectOne(output interface{}, query string, args ...interface{}) error {
	return s.scanOne(output, query, true, args...)
}
func (s *shardConn) SelectMaybe(output interface{}, query string, args ...interface{}) error {
	return s.scanOne(output, query, false, args...)
}
func (s *shardConn) scanOne(output interface{}, query string, required bool, args ...interface{}) error {
	// Check types
	var outputReflectionPtr = reflect.ValueOf(output)
	if !outputReflectionPtr.IsValid() {
		panic(scanOneTypeError)
	}
	if outputReflectionPtr.Kind() != reflect.Ptr {
		panic(scanOneTypeError)
	}
	var outputReflection = outputReflectionPtr.Elem()
	if outputReflection.Kind() != reflect.Ptr {
		panic(scanOneTypeError)
	}

	// Query DB
	var rows, err = s.Query(query, args...)
	if err != nil {
		return err
	}
	defer rows.Close()

	// Reflect onto struct
	columns, err := rows.Columns()
	if err != nil {
		return err
	}
	if !rows.Next() {
		if required {
			return errors.New("SelectOne got 0 rows. Query: " + query + " Args: " + fmt.Sprint(args))
		} else {
			return nil
		}
	}

	var vStruct reflect.Value
	if outputReflection.IsNil() {
		structPtrVal := reflect.New(outputReflection.Type().Elem())
		outputReflection.Set(structPtrVal)
		vStruct = structPtrVal.Elem()
	} else {
		vStruct = outputReflection.Elem()
	}

	err = structFromRow(vStruct, columns, rows)
	if err != nil {
		return err
	}

	if rows.Next() {
		return errors.New("fun/sql.SelectOne: got multiple rows. Query: " + query + " Args: " + fmt.Sprint(args))
	}

	err = rows.Err()
	if err != nil {
		return err
	}

	return nil
}

func structFromRow(outputItemStructVal reflect.Value, columns []string, rows *sql.Rows) (err error) {
	vals := make([]interface{}, len(columns))
	for i, _ := range columns {
		vals[i] = &sql.RawBytes{}
		// vals[i] = &[]byte{}
	}
	err = rows.Scan(vals...)
	if err != nil {
		return
	}

	var uintVal uint64
	var intVal int64
	for i, column := range columns {
		bytes := []byte(*vals[i].(*sql.RawBytes))
		// bytes := []byte(*vals[i].(*[]byte))
		if bytes == nil {
			continue // Leave struct field empty
		}
		var outputItemField = outputItemStructVal.FieldByName(column)
		switch outputItemField.Kind() {
		case reflect.String:
			outputItemField.SetString(string(bytes))
		case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
			uintVal, err = strconv.ParseUint(string(bytes), 10, 64)
			if err != nil {
				return
			}
			outputItemField.SetUint(reflect.ValueOf(uintVal).Uint())
		case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
			intVal, err = strconv.ParseInt(string(bytes), 10, 64)
			if err != nil {
				return
			}
			outputItemField.SetInt(reflect.ValueOf(intVal).Int())
		default:
			err = errors.New("fun/sql: Bad row value for column " + column + ": " + outputItemField.Kind().String())
			return
		}
	}

	return
}
