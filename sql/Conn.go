package sql

import (
	"database/sql"
)

type ConnFun func(ac Conn) error

type Conn interface {
	Autocommit(ConnFun) error
	Transact(ConnFun) error
	Query(query string, args ...interface{}) (rows *sql.Rows, err error)
	Exec(query string, args ...interface{}) (res sql.Result, err error)
	SelectInt(query string, args ...interface{}) (num int, err error)
	SelectString(query string, args ...interface{}) (str string, err error)
	SelectUInt(query string, args ...interface{}) (num uint, err error)
	SelectIntMaybe(query string, args ...interface{}) (num int, found bool, err error)
	SelectStringMaybe(query string, args ...interface{}) (str string, found bool, err error)
	SelectUIntMaybe(query string, args ...interface{}) (num uint, found bool, err error)
	UpdateOne(query string, args ...interface{}) error
	InsertIgnoreId(query string, args ...interface{}) (err error)
	Insert(query string, args ...interface{}) (id int64, err error)
	Select(output interface{}, sql string, args ...interface{}) error
	SelectOne(output interface{}, query string, args ...interface{}) error
	SelectMaybe(output interface{}, query string, args ...interface{}) error
}
