package go_sql_driver_adapter

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
	funSql "github.com/marcuswestin/FunGo/sql"
)

func init() {
	funSql.SetOpener(goSqlDriverOpener)
}

func goSqlDriverOpener(username, password, dbName, host string, port int, connVars funSql.ConnVariables) (*sql.DB, error) {
	sourceString := fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?%s",
		username, password, host, port, dbName, connVars.Join("&"))
	return sql.Open("mysql", sourceString)
}
