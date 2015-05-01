package go_sql_driver_adapter

import (
	"database/sql"
	"fmt"
	"strings"

	_ "github.com/go-sql-driver/mysql"
	funSql "github.com/marcuswestin/FunGo/sql"
)

func init() {
	funSql.SetOpener(goSqlDriverOpener)
}

func goSqlDriverOpener(username, password, dbName, host string, port int, connVars map[string]string) (*sql.DB, error) {
	sourceString := fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?%s",
		username, password, host, port, dbName, joinConnVars(connVars))
	return sql.Open("mysql", sourceString)
}

func joinConnVars(connVars map[string]string) string {
	kvps := make([]string, len(connVars))
	i := 0
	for param, val := range connVars {
		kvps[i] = param + "=" + val
		i += 1
	}
	return strings.Join(kvps, "&")
}
