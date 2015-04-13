package sql

import "database/sql"

type Conn interface {
	Tx
	Autocommit(TxFunc) error
	Transact(TxFunc) error
}

type TxFunc func(tx Tx) error

type Tx interface {
	Query(query string, args ...interface{}) (rows *sql.Rows, err error)
	Exec(query string, args ...interface{}) (res sql.Result, err error)
	ExecIgnoreDuplicateError(query string, args ...interface{}) (res sql.Result, err error)

	InsertIgnoreId(query string, args ...interface{}) (err error)
	InsertIgnoreDuplicates(query string, args ...interface{}) (err error)
	Insert(query string, args ...interface{}) (id int64, err error)

	Update(query string, args ...interface{}) (rowsAffected int64, err error)
	UpdateOne(query string, args ...interface{}) (err error)
	UpdateNum(num int64, query string, args ...interface{}) (err error)

	Select(output interface{}, sql string, args ...interface{}) (err error)
	SelectOne(output interface{}, query string, args ...interface{}) (err error)
	SelectMaybe(output interface{}, query string, args ...interface{}) (err error)

	SelectInt(query string, args ...interface{}) (num int, err error)
	SelectString(query string, args ...interface{}) (str string, err error)
	SelectUint(query string, args ...interface{}) (num uint, err error)

	SelectIntMaybe(query string, args ...interface{}) (num int, found bool, err error)
	SelectStringMaybe(query string, args ...interface{}) (str string, found bool, err error)
	SelectUintMaybe(query string, args ...interface{}) (num uint, found bool, err error)

	SelectIntForce(query string, args ...interface{}) (num int, err error)
	SelectStringForce(query string, args ...interface{}) (str string, err error)
	SelectUintForce(query string, args ...interface{}) (num uint, err error)
}
