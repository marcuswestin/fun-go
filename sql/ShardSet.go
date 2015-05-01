package sql

import (
	"database/sql"
	"fmt"
	"math/rand"
	"strconv"
)

type ShardSet struct {
	username     string
	password     string
	host         string
	port         int
	dbNamePrefix string
	numShards    int
	maxShards    int
	maxConns     int
	shards       []*shard
}

func NewShardSet(username string, password string, host string, port int, dbNamePrefix string, numShards int, maxShards int, maxConns int) *ShardSet {
	return &ShardSet{
		username:     username,
		password:     password,
		host:         host,
		port:         port,
		dbNamePrefix: dbNamePrefix,
		numShards:    numShards,
		maxShards:    maxShards,
		maxConns:     maxConns,
	}
}

func (s *ShardSet) Connect() (err error) {
	s.shards = make([]*shard, s.numShards)
	for i := 0; i < s.numShards; i++ {
		err = s.addShard(i)
		if err != nil {
			return
		}
	}
	return
}

func (s *ShardSet) Shard(id int64) Conn {
	if id == 0 {
		panic("Bad shard index id 0")
	}
	shardIndex := ((id - 1) % int64(s.maxShards)) // 1->0, 2->1, 3->2 ..., 65000->65000, 65001->0, 65002->1
	return s.shards[shardIndex]
}

func (s *ShardSet) All() []Conn {
	all := make([]Conn, len(s.shards))
	for i, shard := range s.shards {
		all[i] = Conn(shard)
	}
	return all
}

func (s *ShardSet) RandomShard() Conn {
	return s.shards[randomBetween(0, len(s.shards))]
}

func (s *ShardSet) addShard(i int) (err error) {
	autoIncrementOffset := i + 1
	dbName := fmt.Sprint(s.dbNamePrefix, autoIncrementOffset)
	s.shards[i], err = newShard(s, dbName, autoIncrementOffset)
	if err != nil {
		return
	}
	return
}

func newShard(s *ShardSet, dbName string, autoIncrementOffset int) (*shard, error) {
	connVars := map[string]string{
		"autocommit":               "true",
		"auto_increment_increment": strconv.Itoa(s.maxShards),
		"auto_increment_offset":    strconv.Itoa(autoIncrementOffset),
		"sql_mode":                 "STRICT_ALL_TABLES",
	}

	db, err := dbOpener(s.username, s.password, dbName, s.host, s.port, connVars)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(s.maxConns)
	// db.SetMaxIdleConns(n)
	err = db.Ping()
	if err != nil {
		return nil, err
	}
	return &shard{db, shardConn{db}}, nil
}

func SetOpener(opener Opener) {
	if dbOpener != nil {
		panic("Opener already set - did you import two driver adapters?")
	}
	dbOpener = opener
}

type Opener func(username, password, dbName, host string, port int, connVars map[string]string) (*sql.DB, error)

var dbOpener Opener

func randomBetween(min, max int) int {
	return rand.Intn(max-min) + min // random int in [min, max)
}
