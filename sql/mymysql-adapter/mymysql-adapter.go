package myysql_adapter

import (
	"database/sql"
	"fmt"

	_ "github.com/asappinc/mymysql/godrv"
	funSql "github.com/marcuswestin/FunGo/sql"
)

func init() {
	funSql.SetOpener(mymysqlDriverOpener)
}

func mymysqlDriverOpener(username, password, dbName, host string, port int, connVars funSql.ConnVariables) (*sql.DB, error) {
	sourceString := fmt.Sprintf(
		"tcp:%s:%d,%s*%s/%s/%s",
		host, port, connVars.Join(","), dbName, username, password)
	return sql.Open("mymysql", sourceString)
}
