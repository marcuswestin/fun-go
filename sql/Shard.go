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
func IsDuplicateExecError(err error) bool {
	return strings.HasPrefix(err.Error(), "sql.Exec Error: Error 1060: Duplicate column name") ||
		strings.HasPrefix(err.Error(), "sql.Exec Error: Error 1061: Duplicate key name") ||
		strings.HasPrefix(err.Error(), "sql.Exec Error: Error 1050: Table") ||
		strings.HasPrefix(err.Error(), "sql.Exec Error: Error 1022: Can't write; duplicate key in table")
}
func (s *shardConn) ExecIgnoreDuplicateError(query string, args ...interface{}) (res sql.Result, err error) {
	res, err = s.Exec(query, args...)
	if err != nil && IsDuplicateExecError(err) {
		err = nil
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

func (s *shardConn) SelectInt(query string, args ...interface{}) (num int64, err error) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		err = errors.New("Query returned no rows: " + query)
	}
	return
}

func (s *shardConn) SelectString(query string, args ...interface{}) (str string, err error) {
	var nullStr sql.NullString
	found, err := s.queryOne(query, args, &nullStr)
	if err != nil {
		return
	}
	if found {
		str = nullStr.String
	} else {
		err = errors.New("Query returned no rows: " + query)
	}
	return
}

func (s *shardConn) SelectUint(query string, args ...interface{}) (num uint, err error) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		err = errors.New("Query returned no rows: " + query)
	}
	return
}

func (s *shardConn) SelectIntForce(query string, args ...interface{}) (num int64, err error) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		panic("Query returned no rows: " + query)
	}
	return
}

func (s *shardConn) SelectStringForce(query string, args ...interface{}) (str string, err error) {
	found, err := s.queryOne(query, args, &str)
	if err != nil {
		return
	}
	if !found {
		panic("Query returned no rows: " + query)
	}
	return
}

func (s *shardConn) SelectUintForce(query string, args ...interface{}) (num uint, err error) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		panic("Query returned no rows: " + query)
	}
	return
}

func (s *shardConn) SelectIntMaybe(query string, args ...interface{}) (num int64, found bool, err error) {
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
		msg := fmt.Sprint("UpdateNum expected ", num, ", affected ", rowsAffected, ". Query: ", query, " Args: ", args)
		return errors.New(msg)
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

func IsDuplicateEntryError(err error) bool {
	return strings.Contains(err.Error(), "Duplicate entry")
}
func (s *shardConn) InsertIgnoreDuplicates(query string, args ...interface{}) (err error) {
	_, err = s.Insert(query, args...)
	if err != nil && IsDuplicateEntryError(err) {
		err = nil
	}
	return
}

func (s *shardConn) Insert(query string, args ...interface{}) (id int64, err error) {
	res, err := s.Exec(query, args...)
	if err != nil {
		return
	}
	return res.LastInsertId()
}

func (s *shardConn) Select(output interface{}, query string, args ...interface{}) error {
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
	outputReflection.Set(reflect.MakeSlice(outputReflection.Type(), 0, 0))

	// Query DB
	var rows, err = s.Query(query, args...)
	if err != nil {
		return err
	}
	defer rows.Close()
	columns, err := rows.Columns()
	if err != nil {
		return err
	}

	valType := outputReflection.Type().Elem()
	isStruct := (valType.Kind() == reflect.Ptr && valType.Elem().Kind() == reflect.Struct)
	if isStruct {
		// Reflect onto structs
		for rows.Next() {
			structPtrVal := reflect.New(valType.Elem())
			outputItemStructVal := structPtrVal.Elem()
			err = structFromRow(outputItemStructVal, columns, rows, query)
			if err != nil {
				return err
			}
			outputReflection.Set(reflect.Append(outputReflection, structPtrVal))
		}
	} else {
		if len(columns) != 1 {
			return errors.New("Expected single column in select statement for slice of non-struct values")
		}
		for rows.Next() {
			rawBytes := &sql.RawBytes{}
			err = rows.Scan(rawBytes)
			if err != nil {
				return err
			}
			outputValue := reflect.New(valType).Elem()
			err = scanColumnValue(columns[0], outputValue, rawBytes)
			if err != nil {
				return err
			}
			if err != nil {
				return err
			}
			outputReflection.Set(reflect.Append(outputReflection, outputValue))
		}
	}

	return rows.Err()
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

	err = structFromRow(vStruct, columns, rows, query)
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

type scanError struct {
	err   error
	query string
}

func (s *scanError) Error() string {
	return s.err.Error() + " [SQL: " + s.query + "]"
}

func structFromRow(outputItemStructVal reflect.Value, columns []string, rows *sql.Rows, query string) (err error) {
	vals := make([]interface{}, len(columns))
	for i, _ := range columns {
		vals[i] = &sql.RawBytes{}
	}
	err = rows.Scan(vals...)
	if err != nil {
		err = &scanError{err, query}
		return
	}

	for i, column := range columns {
		err = scanColumnValue(column, outputItemStructVal.FieldByName(column), vals[i].(*sql.RawBytes))
		if err != nil {
			return
		}
	}

	return
}

func scanColumnValue(column string, reflectVal reflect.Value, value *sql.RawBytes) (err error) {
	bytes := []byte(*value)
	if bytes == nil {
		return // Leave struct field empty
	}
	switch reflectVal.Kind() {
	case reflect.String:
		reflectVal.SetString(string(bytes))
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		var uintVal uint64
		uintVal, err = strconv.ParseUint(string(bytes), 10, 64)
		if err != nil {
			return
		}
		reflectVal.SetUint(reflect.ValueOf(uintVal).Uint())
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		var intVal int64
		intVal, err = strconv.ParseInt(string(bytes), 10, 64)
		if err != nil {
			return
		}
		reflectVal.SetInt(reflect.ValueOf(intVal).Int())
	default:
		if reflectVal.Kind() == reflect.Slice { // && reflectVal. == reflect.Uint8 {
			// byte slice
			reflectVal.SetBytes(bytes)
		} else {
			err = errors.New("fun/sql: Bad row value for column " + column + ": " + reflectVal.Kind().String())
			return
		}
	}
	return
}
