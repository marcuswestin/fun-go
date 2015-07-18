package sql

import (
	"database/sql"
	"errors"
	"reflect"
	"strconv"
	"strings"

	"github.com/marcuswestin/fun-go/errs"
)

type TxFunc func(shard *Shard) errs.Err

type Shard struct {
	db      *sql.DB // Nil for transaction and autocommit shard structs
	sqlConn interface {
		Exec(query string, args ...interface{}) (sql.Result, error)
		Query(query string, args ...interface{}) (*sql.Rows, error)
	}
}

func (s *Shard) Autocommit(acFun TxFunc) errs.Err {
	conn, err := s.db.Begin()
	if err != nil {
		return errs.Wrap(err, "Could not open autocommit", nil)
	}

	return acFun(&Shard{nil, conn})
}

func (s *Shard) Transact(txFun TxFunc) errs.Err {
	conn, stdErr := s.db.Begin()
	if stdErr != nil {
		return errs.Wrap(stdErr, "Could not open transaction", nil)
	}

	err := txFun(&Shard{nil, conn})
	if err != nil {
		rbErr := conn.Rollback()
		if rbErr != nil {
			return errs.Wrap(rbErr, "Transact rollback error", errs.Info{"TransactionError": err})
		}

	} else {
		stdErr = conn.Commit()
		if stdErr != nil {
			return errs.Wrap(stdErr, "Could not commit transaction", nil)
		}
	}

	return nil
}

// Query with fixed args
func (s *Shard) Query(query string, args ...interface{}) (*sql.Rows, errs.Err) {
	fixArgs(args)
	rows, stdErr := s.sqlConn.Query(query, args...)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, "Query sqlConn.Query() error", errInfo(query, args))
	}
	return rows, nil
}

// Execute with fixed args
func (s *Shard) Exec(query string, args ...interface{}) (sql.Result, errs.Err) {
	fixArgs(args)
	res, stdErr := s.sqlConn.Exec(query, args...)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, "Exec sqlConn.Exec() error", errInfo(query, args))
	}
	return res, nil
}
func IsDuplicateExecError(err errs.Err) bool {
	str := err.StandardError().Error()
	return strings.HasPrefix(str, "sql.Exec Error: Error 1060: Duplicate column name") ||
		strings.HasPrefix(str, "sql.Exec Error: Error 1061: Duplicate key name") ||
		strings.HasPrefix(str, "sql.Exec Error: Error 1050: Table") ||
		strings.HasPrefix(str, "sql.Exec Error: Error 1022: Can't write; duplicate key in table")
}
func (s *Shard) ExecIgnoreDuplicateError(query string, args ...interface{}) (res sql.Result, err errs.Err) {
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

func (s *Shard) SelectInt(query string, args ...interface{}) (num int64, err errs.Err) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		err = errs.New("Query returned no rows", errInfo(query, args))
		return
	}
	return
}

func (s *Shard) SelectString(query string, args ...interface{}) (str string, err errs.Err) {
	var nullStr sql.NullString
	found, err := s.queryOne(query, args, &nullStr)
	if err != nil {
		return
	}
	if found {
		str = nullStr.String
	} else {
		err = errs.New("Query returned no rows", errInfo(query, args))
		return
	}
	return
}

func (s *Shard) SelectUint(query string, args ...interface{}) (num uint, err errs.Err) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		err = errs.New("Query returned no rows", errInfo(query, args))
		return
	}
	return
}

func (s *Shard) SelectIntForce(query string, args ...interface{}) (num int64, err errs.Err) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		panic("Query returned no rows: " + query)
	}
	return
}

func (s *Shard) SelectStringForce(query string, args ...interface{}) (str string, err errs.Err) {
	found, err := s.queryOne(query, args, &str)
	if err != nil {
		return
	}
	if !found {
		panic("Query returned no rows: " + query)
	}
	return
}

func (s *Shard) SelectUintForce(query string, args ...interface{}) (num uint, err errs.Err) {
	found, err := s.queryOne(query, args, &num)
	if err != nil {
		return
	}
	if !found {
		panic("Query returned no rows: " + query)
	}
	return
}

func (s *Shard) SelectIntMaybe(query string, args ...interface{}) (num int64, found bool, err errs.Err) {
	found, err = s.queryOne(query, args, &num)
	return
}

func (s *Shard) SelectStringMaybe(query string, args ...interface{}) (str string, found bool, err errs.Err) {
	found, err = s.queryOne(query, args, &str)
	return
}

func (s *Shard) SelectUintMaybe(query string, args ...interface{}) (num uint, found bool, err errs.Err) {
	found, err = s.queryOne(query, args, &num)
	return
}

func (s *Shard) queryOne(query string, args []interface{}, out interface{}) (found bool, err errs.Err) {
	rows, err := s.Query(query, args...)
	if err != nil {
		return
	}
	defer rows.Close()

	if rows.Next() {
		stdErr := rows.Scan(out)
		if stdErr != nil {
			err = errs.Wrap(stdErr, "queryOne rows.Scan error", errInfo(query, args))
			return
		}
		if rows.Next() {
			err = errs.New("queryOne query returned too many rows", errInfo(query, args))
			return
		}
		found = true
	}

	stdErr := rows.Err()
	if stdErr != nil {
		err = errs.Wrap(stdErr, "queryOne rows.Err", errInfo(query, args))
		return
	}

	return
}

func (s *Shard) UpdateOne(query string, args ...interface{}) (err errs.Err) {
	return s.UpdateNum(1, query, args...)
}

func (s *Shard) UpdateNum(num int64, query string, args ...interface{}) (err errs.Err) {
	rowsAffected, err := s.Update(query, args...)
	if err != nil {
		return err
	}
	if rowsAffected != num {
		info := errInfo(query, args)
		info["ExpectedRows"] = num
		info["AffectedRows"] = rowsAffected
		return errs.New("UpdateNum affected unexpected number of rows", info)
	}
	return
}

func (s *Shard) Update(query string, args ...interface{}) (rowsAffected int64, err errs.Err) {
	res, err := s.Exec(query, args...)
	if err != nil {
		return
	}

	rowsAffected, stdErr := res.RowsAffected()
	if stdErr != nil {
		err = errs.Wrap(stdErr, "Update RowsAffected error", errInfo(query, args))
		return
	}
	return
}

func (s *Shard) InsertIgnoreId(query string, args ...interface{}) (err errs.Err) {
	_, err = s.Insert(query, args...)
	return
}

func IsDuplicateEntryError(err errs.Err) bool {
	str := err.StandardError().Error()
	return strings.Contains(str, "Duplicate entry")
}
func (s *Shard) InsertIgnoreDuplicates(query string, args ...interface{}) (err errs.Err) {
	_, err = s.Insert(query, args...)
	if err != nil && IsDuplicateEntryError(err) {
		err = nil
	}
	return
}

func (s *Shard) Insert(query string, args ...interface{}) (id int64, err errs.Err) {
	res, err := s.Exec(query, args...)
	if err != nil {
		return
	}
	id, stdErr := res.LastInsertId()
	if stdErr != nil {
		err = errs.Wrap(stdErr, "Insert LastInsertIderror", errInfo(query, args))
		return
	}
	return
}

func (s *Shard) Select(output interface{}, query string, args ...interface{}) errs.Err {
	// Check types
	var outputPtr = reflect.ValueOf(output)
	if outputPtr.Kind() != reflect.Ptr {
		return errs.New("Select expects a pointer to a slice of items", errInfo(query, args))
	}
	var outputReflection = reflect.Indirect(outputPtr)
	if outputReflection.Kind() != reflect.Slice {
		return errs.New("Select expects items to be a slice", errInfo(query, args))
	}
	if outputReflection.Len() != 0 {
		return errs.New("Select expects items to be empty", errInfo(query, args))
	}
	outputReflection.Set(reflect.MakeSlice(outputReflection.Type(), 0, 0))

	// Query DB
	var rows, err = s.Query(query, args...)
	if err != nil {
		return err
	}
	defer rows.Close()
	columns, stdErr := rows.Columns()
	if stdErr != nil {
		return errs.Wrap(stdErr, "Select rows.Columns error", errInfo(query, args))
	}

	valType := outputReflection.Type().Elem()
	isStruct := (valType.Kind() == reflect.Ptr && valType.Elem().Kind() == reflect.Struct)
	if isStruct {
		// Reflect onto structs
		for rows.Next() {
			structPtrVal := reflect.New(valType.Elem())
			outputItemStructVal := structPtrVal.Elem()
			err = structFromRow(outputItemStructVal, columns, rows, query, args)
			if err != nil {
				return err
			}
			outputReflection.Set(reflect.Append(outputReflection, structPtrVal))
		}
	} else {
		if len(columns) != 1 {
			return errs.New("Select expected single column in select statement for slice of non-struct values", errInfo(query, args))
		}
		for rows.Next() {
			rawBytes := &sql.RawBytes{}
			stdErr = rows.Scan(rawBytes)
			if stdErr != nil {
				return errs.Wrap(stdErr, "Select rows.Scan error", errInfo(query, args))
			}
			outputValue := reflect.New(valType).Elem()
			stdErr := scanColumnValue(columns[0], outputValue, rawBytes)
			if stdErr != nil {
				return errs.Wrap(stdErr, "Select scanColumnValue error", errInfo(query, args))
			}
			if err != nil {
				return err
			}
			outputReflection.Set(reflect.Append(outputReflection, outputValue))
		}
	}

	stdErr = rows.Err()
	if err != nil {
		return errs.Wrap(stdErr, "Select rows.Err() error", errInfo(query, args))
	}
	return nil
}

const scanOneTypeError = "fun/sql.SelectOne: expects a **struct, e.g var person *Person; c.SelectOne(&person, sql)"

func (s *Shard) SelectOne(output interface{}, query string, args ...interface{}) errs.Err {
	return s.scanOne(output, query, true, args...)
}
func (s *Shard) SelectMaybe(output interface{}, query string, args ...interface{}) errs.Err {
	return s.scanOne(output, query, false, args...)
}
func (s *Shard) scanOne(output interface{}, query string, required bool, args ...interface{}) errs.Err {
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
	rows, err := s.Query(query, args...)
	if err != nil {
		return err
	}
	defer rows.Close()

	// Reflect onto struct
	columns, stdErr := rows.Columns()
	if stdErr != nil {
		return errs.Wrap(stdErr, "rows.Columns() error", errInfo(query, args))
	}
	if !rows.Next() {
		if required {
			return errs.New("scanOne got no rows", errInfo(query, args))
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

	err = structFromRow(vStruct, columns, rows, query, args)
	if err != nil {
		return err
	}

	if rows.Next() {
		return errs.New("scanOne got multiple rows", errInfo(query, args))
	}

	stdErr = rows.Err()
	if stdErr != nil {
		return errs.Wrap(stdErr, "scanOne rows.Err() error", errInfo(query, args))
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

func structFromRow(outputItemStructVal reflect.Value, columns []string, rows *sql.Rows, query string, args []interface{}) errs.Err {
	vals := make([]interface{}, len(columns))
	for i, _ := range columns {
		vals[i] = &sql.RawBytes{}
	}
	stdErr := rows.Scan(vals...)
	if stdErr != nil {
		return errs.Wrap(stdErr, "structFromRow error", errInfo(query, args))
	}

	for i, column := range columns {
		stdErr = scanColumnValue(column, outputItemStructVal.FieldByName(column), vals[i].(*sql.RawBytes))
		if stdErr != nil {
			return errs.Wrap(stdErr, "structFromRow scanColumnValue error", errInfo(query, args))
		}
	}

	return nil
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

func errInfo(query string, args []interface{}) errs.Info {
	return errs.Info{"Query": query, "Args": args}
}
