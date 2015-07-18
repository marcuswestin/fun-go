package shards

import (
	"database/sql"

	"github.com/marcuswestin/fun-go/errs"
)

type Conn interface {
	Tx
	Autocommit(TxFunc) errs.Err
	Transact(TxFunc) errs.Err
}

type TxFunc func(tx Tx) errs.Err

type Tx interface {
	Query(query string, args ...interface{}) (rows *sql.Rows, err errs.Err)
	Exec(query string, args ...interface{}) (res sql.Result, err errs.Err)
	ExecIgnoreDuplicateError(query string, args ...interface{}) (res sql.Result, err errs.Err)

	InsertIgnoreId(query string, args ...interface{}) (err errs.Err)
	InsertIgnoreDuplicates(query string, args ...interface{}) (err errs.Err)
	Insert(query string, args ...interface{}) (id int64, err errs.Err)

	Update(query string, args ...interface{}) (rowsAffected int64, err errs.Err)
	UpdateOne(query string, args ...interface{}) (err errs.Err)
	UpdateNum(num int64, query string, args ...interface{}) (err errs.Err)

	Select(output interface{}, sql string, args ...interface{}) (err errs.Err)
	SelectOne(output interface{}, query string, args ...interface{}) (err errs.Err)
	SelectMaybe(output interface{}, query string, args ...interface{}) (err errs.Err)

	SelectInt(query string, args ...interface{}) (num int64, err errs.Err)
	SelectString(query string, args ...interface{}) (str string, err errs.Err)
	SelectUint(query string, args ...interface{}) (num uint, err errs.Err)

	SelectIntMaybe(query string, args ...interface{}) (num int64, found bool, err errs.Err)
	SelectStringMaybe(query string, args ...interface{}) (str string, found bool, err errs.Err)
	SelectUintMaybe(query string, args ...interface{}) (num uint, found bool, err errs.Err)

	SelectIntForce(query string, args ...interface{}) (num int64, err errs.Err)
	SelectStringForce(query string, args ...interface{}) (str string, err errs.Err)
	SelectUintForce(query string, args ...interface{}) (num uint, err errs.Err)
}
