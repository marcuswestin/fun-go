package myysql_adapter

import (
	"database/sql"
	"fmt"

	funSql "github.com/marcuswestin/FunGo/sql"
	"github.com/ziutek/mymysql/godrv"
)

func init() {
	funSql.SetOpener(mymysqlDriverOpener)
}

func mymysqlDriverOpener(username, password, dbName, host string, port int, connVars map[string]string) (*sql.DB, error) {
	setConnVars(connVars)

	// panic("TODO Include host/port")
	sourceString := fmt.Sprintf(
		"%s/%s/%s",
		dbName, username, password)
	return sql.Open("mymysql", sourceString)
}

func setConnVars(connVars map[string]string) {
	for param, val := range connVars {
		cmd := "SET " + param + "=" + val
		fmt.Println("MYSQL:", cmd)
		godrv.Register(cmd)
	}
	return
}
