package myysql_adapter

import (
	"database/sql"
	"fmt"

	_ "github.com/asappinc/mymysql/godrv"
	"github.com/marcuswestin/fun-go/sql"
)

func init() {
	shards.SetOpener(mymysqlDriverOpener)
}

func mymysqlDriverOpener(username, password, dbName, host string, port int, connVars shards.ConnVariables) (*sql.DB, error) {
	sourceString := fmt.Sprintf(
		"tcp:%s:%d,%s*%s/%s/%s",
		host, port, connVars.Join(","), dbName, username, password)
	return sql.Open("mymysql", sourceString)
}
