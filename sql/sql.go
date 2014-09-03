package sql

import (
	"database/sql"
	"errors"
	"fmt"
	"math/rand"
	"reflect"
	"strconv"
	"strings"
)

var MaxShards = 64000

type ShardSet struct {
	username               string
	password               string
	host                   string
	port                   int
	dbNamePrefix           string
	numShards              int
	numConnectionsPerShard int
	pools                  []Conn
}

func NewShardSet(username string, password string, host string, port int, dbNamePrefix string, numShards int, numConnectionsPerShard int) *ShardSet {
	return &ShardSet{
		username:               username,
		password:               password,
		host:                   host,
		port:                   port,
		dbNamePrefix:           dbNamePrefix,
		numShards:              numShards,
		numConnectionsPerShard: numConnectionsPerShard,
	}
}

func (s *ShardSet) Connect() (err error) {
	s.pools = make([]Conn, s.numShards)
	var pool Conn
	for i := 0; i < s.numShards; i++ {
		autoIncrementOffset := i + 1
		dbName := s.dbNamePrefix + strconv.Itoa(autoIncrementOffset)
		pool, err = NewPool(
			DbSourceString(s.username, s.password, s.host, s.port, dbName, MaxShards, autoIncrementOffset),
			s.numConnectionsPerShard)
		if err != nil {
			return
		}
		s.pools[i] = pool
	}
	return
}

func (s *ShardSet) Pool(id int64) Conn {
	if id == 0 {
		panic("Bad shard index id 0")
	}
	shardIndex := ((id - 1) % int64(MaxShards)) // 1->0, 2->1, 3->2 ..., 65000->65000, 65001->0, 65002->1
	return s.pools[shardIndex]
}

func randomBetween(min, max int) int {
	return rand.Intn(max-min) + min // random int in [min, max)
}

func (s *ShardSet) RandomPool() Conn {
	return s.pools[randomBetween(0, len(s.pools))]
}

func DbSourceString(username string, password string, host string, port int, dbName string, autoIncrementIncrement int, autoIncrementOffset int) string {
	return fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?strict=true&clientFoundRows=true&autocommit=true&auto_increment_increment=%d&auto_increment_offset=%d&sql_mode=STRICT_ALL_TABLES",
		username, password, host, port, dbName, autoIncrementIncrement, autoIncrementOffset)
}

type Pool struct {
	queue chan *sql.DB
}

func NewPool(sourceString string, numConnections int) (pool Conn, err error) {
	queue := make(chan *sql.DB, numConnections)
	var conn *sql.DB
	for i := 0; i < numConnections; i++ {
		conn, err = sql.Open("mysql", sourceString)
		if err != nil {
			return
		}
		err = conn.Ping()
		if err != nil {
			return
		}

		queue <- conn
	}
	pool = &Pool{queue}
	return
}

func (p *Pool) Autocommit(acFun ConnFun) (err error) {
	conn := <-p.queue
	defer func() { p.queue <- conn }()

	acPool := &Pool{queue: make(chan *sql.DB, 1)}
	acPool.queue <- conn

	return acFun(acPool)
}

func (p *Pool) Transact(txFun ConnFun) (err error) {
	conn := <-p.queue
	defer func() { p.queue <- conn }()

	txPool := &Pool{queue: make(chan *sql.DB, 1)}
	txPool.queue <- conn

	_, err = conn.Exec("START TRANSACTION")
	if err != nil {
		return
	}

	err = txFun(txPool)
	if err != nil {
		return rollback(conn, err)
	}

	_, err = conn.Exec("COMMIT")
	if err != nil {
		return
	}

	return
}

func rollback(conn *sql.DB, err error) error {
	_, rbErr := conn.Exec("ROLLBACK")
	if rbErr != nil {
		err = errors.New("Rollback error: " + rbErr.Error() + " Query error: " + err.Error())
	}
	return err
}

// Query with fixed args
func (p *Pool) Query(query string, args ...interface{}) (rows *sql.Rows, err error) {
	conn := <-p.queue
	defer func() { p.queue <- conn }()

	FixArgs(args)
	rows, err = conn.Query(query, args...)
	if err != nil {
		err = errors.New("sql.Query Error: " + err.Error() + ". Query: " + query + " Args: " + fmt.Sprint(args))
	}
	return
}

// Execute with fixed args
func (p *Pool) Exec(query string, args ...interface{}) (res sql.Result, err error) {
	conn := <-p.queue
	defer func() { p.queue <- conn }()

	FixArgs(args)
	res, err = conn.Exec(query, args...)
	if err != nil {
		err = errors.New("sql.Exec Error: " + err.Error() + ". Query: " + query + " Args: " + fmt.Sprint(args))
	}
	return
}

/*
Fix args by converting them to values of their underlying kind.
This avoids problems in database/sql with e.g custom string types.
Without FixArgs, the following code:

	type Foo string
	...
	pool.Query("SELECT * WHERE Foo=?", Foo("bar"))

would give you the error:

	sql: converting Exec argument #1's type: unsupported type Foo, a string
*/
func FixArgs(args []interface{}) {
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

func (p *Pool) SelectInt(query string, args ...interface{}) (num int, err error) {
	found, err := p.queryOne(query, args, &num)
	if !found {
		err = errors.New("Query returned no rows")
	}
	return
}

func (p *Pool) SelectString(query string, args ...interface{}) (str string, err error) {
	found, err := p.queryOne(query, args, &str)
	if !found {
		err = errors.New("Query returned no rows")
	}
	return
}

func (p *Pool) SelectUint(query string, args ...interface{}) (num uint, err error) {
	found, err := p.queryOne(query, args, &num)
	if !found {
		err = errors.New("Query returned no rows")
	}
	return
}

func (p *Pool) SelectIntForce(query string, args ...interface{}) (num int, err error) {
	found, err := p.queryOne(query, args, &num)
	if !found {
		panic("Query returned no rows")
	}
	return
}

func (p *Pool) SelectStringForce(query string, args ...interface{}) (str string, err error) {
	found, err := p.queryOne(query, args, &str)
	if !found {
		panic("Query returned no rows")
	}
	return
}

func (p *Pool) SelectUintForce(query string, args ...interface{}) (num uint, err error) {
	found, err := p.queryOne(query, args, &num)
	if !found {
		panic("Query returned no rows")
	}
	return
}

func (p *Pool) SelectIntMaybe(query string, args ...interface{}) (num int, found bool, err error) {
	found, err = p.queryOne(query, args, &num)
	return
}

func (p *Pool) SelectStringMaybe(query string, args ...interface{}) (str string, found bool, err error) {
	found, err = p.queryOne(query, args, &str)
	return
}

func (p *Pool) SelectUintMaybe(query string, args ...interface{}) (num uint, found bool, err error) {
	found, err = p.queryOne(query, args, &num)
	return
}

func (p *Pool) queryOne(query string, args []interface{}, out interface{}) (found bool, err error) {
	rows, err := p.Query(query, args...)
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

// type TransactFunc func() error

// func (p *Pool) Transact(f TransactFunc) (err error) {
// 	conn := <-p.queue
// 	defer func() { p.queue <- conn }()

// 	_, err = conn.Exec("START TRANSACTION")
// 	if err != nil {
// 		return
// 	}

// 	err = f(conn)
// 	if err != nil {
// 		_, rollbackError := conn.Exec("ROLLBACK")
// 		if rollbackError != nil {
// 			panic("Could not rollback transaction. TransactionFunc error: " + err.Error() + ". Rollback error:" + rollbackError.Error())
// 		}

// 	} else {
// 		_, err = conn.Exec("COMMIT")
// 	}

// 	return
// }

func (p *Pool) UpdateOne(query string, args ...interface{}) (err error) {
	return p.UpdateNum(1, query, args...)
}

func (p *Pool) UpdateNum(num int64, query string, args ...interface{}) (err error) {
	rowsAffected, err := p.Update(query, args...)
	if err != nil {
		return
	}
	if rowsAffected != num {
		return errors.New(fmt.Sprintf("UpdateOne affected %d rows. Query: %q Args: %q", rowsAffected, query, args))
	}
	return
}

func (p *Pool) Update(query string, args ...interface{}) (rowsAffected int64, err error) {
	res, err := p.Exec(query, args...)
	if err != nil {
		return
	}

	rowsAffected, err = res.RowsAffected()
	return
}

func (p *Pool) InsertIgnoreId(query string, args ...interface{}) (err error) {
	_, err = p.Insert(query, args...)
	return
}

func (p *Pool) InsertIgnoreDuplicates(query string, args ...interface{}) (err error) {
	_, err = p.Insert(query, args...)
	if err != nil && strings.Contains(err.Error(), "Duplicate entry") {
		err = nil
	}
	return
}

func (p *Pool) Insert(query string, args ...interface{}) (id int64, err error) {
	res, err := p.Exec(query, args...)
	if err != nil {
		return
	}
	id, err = res.LastInsertId()
	return
}

func (p *Pool) Select(output interface{}, sql string, args ...interface{}) error {
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
	var rows, err = p.Query(sql, args...)
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

const selectOneTypeError = "fun/sql.SelectOne: expects a **struct, e.g var person *Person; c.SelectOne(&person, sql)"

func (p *Pool) SelectOne(output interface{}, query string, args ...interface{}) error {
	return p.selectOne(output, query, true, args...)
}
func (p *Pool) SelectMaybe(output interface{}, query string, args ...interface{}) error {
	return p.selectOne(output, query, false, args...)
}
func (p *Pool) selectOne(output interface{}, query string, required bool, args ...interface{}) error {
	// Check types
	var outputReflectionPtr = reflect.ValueOf(output)
	if !outputReflectionPtr.IsValid() {
		panic(selectOneTypeError)
	}
	if outputReflectionPtr.Kind() != reflect.Ptr {
		panic(selectOneTypeError)
	}
	var outputReflection = outputReflectionPtr.Elem()
	if outputReflection.Kind() != reflect.Ptr {
		panic(selectOneTypeError)
	}

	// Query DB
	var rows, err = p.Query(query, args...)
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
