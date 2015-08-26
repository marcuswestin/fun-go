package myysql_adapter

import (
	"database/sql"
	"fmt"

	_ "github.com/asappinc/mymysql/godrv"
	"github.com/marcuswestin/fun-go/errs"
	funGoSql "github.com/marcuswestin/fun-go/sql"
)

func init() {
	funGoSql.SetOpener(mymysqlDriverOpener)
}

func mymysqlDriverOpener(username, password, dbName, host string, port int, connVars funGoSql.ConnVariables) (*sql.DB, error) {
	sourceString := fmt.Sprintf(
		"tcp:%s:%d,%s*%s/%s/%s",
		host, port, connVars.Join(","), dbName, username, password)
	db, stdErr := sql.Open("mymysql", sourceString)
	if stdErr != nil {
		return nil, errs.Wrap(stdErr, errs.Info{})
	}
	return db, nil
}
