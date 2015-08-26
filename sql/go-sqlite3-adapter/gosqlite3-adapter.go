package myysql_adapter

import (
	"database/sql"

	"github.com/marcuswestin/fun-go/errs"
	funGoSql "github.com/marcuswestin/fun-go/sql"
	_ "github.com/mattn/go-sqlite3"
)

func init() {
	funGoSql.SetOpener(mymysqlDriverOpener)
}

func mymysqlDriverOpener(username, password, dbName, host string, port int, connVars funGoSql.ConnVariables) (*sql.DB, errs.Err) {
	db, stdErr := sql.Open("sqlite3", dbName)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{})
	}
	return db, nil
}
