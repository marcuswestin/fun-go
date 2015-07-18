package go_sql_driver_adapter

import (
	"database/sql"
	"fmt"

	_ "github.com/go-sql-driver/mysql"
	"github.com/marcuswestin/fun-go/sql"
)

func init() {
	shards.SetOpener(goSqlDriverOpener)
}

func goSqlDriverOpener(username, password, dbName, host string, port int, connVars shards.ConnVariables) (*sql.DB, error) {
	sourceString := fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?%s",
		username, password, host, port, dbName, connVars.Join("&"))
	return sql.Open("mysql", sourceString)
}
