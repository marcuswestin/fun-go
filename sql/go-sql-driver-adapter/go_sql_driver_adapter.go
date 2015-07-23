package go_sql_driver_adapter

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
	"github.com/marcuswestin/fun-go/errs"
	funGoSql "github.com/marcuswestin/fun-go/sql"
)

func init() {
	funGoSql.SetOpener(goSqlDriverOpener)
}

func goSqlDriverOpener(username, password, dbName, host string, port int, connVars funGoSql.ConnVariables) (*sql.DB, errs.Err) {
	sourceString := fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?%s",
		username, password, host, port, dbName, connVars.Join("&"))
	db, stdErr := sql.Open("mysql", sourceString)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{})
	}
	return db, nil
}
