package sql

import (
	"database/sql"
	"fmt"
	"math/rand"
)

type ShardSet struct {
	username     string
	password     string
	host         string
	port         int
	dbNamePrefix string
	numShards    int
	maxShards    int
	shards       []*shard
}

func NewShardSet(username string, password string, host string, port int, dbNamePrefix string, numShards int, maxShards int) *ShardSet {
	return &ShardSet{
		username:     username,
		password:     password,
		host:         host,
		port:         port,
		dbNamePrefix: dbNamePrefix,
		numShards:    numShards,
		maxShards:    maxShards,
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
	sourceString := dbSourceString(s.username, s.password, s.host, s.port,
		dbName, s.maxShards, autoIncrementOffset)
	s.shards[i], err = newShard(sourceString)
	if err != nil {
		return
	}
	return
}

func newShard(sourceString string) (s *shard, err error) {
	db, err := sql.Open("mysql", sourceString)
	if err != nil {
		return
	}
	err = db.Ping()
	if err != nil {
		return
	}
	return &shard{db, shardConn{db}}, nil
}

func randomBetween(min, max int) int {
	return rand.Intn(max-min) + min // random int in [min, max)
}

func dbSourceString(username string, password string, host string, port int, dbName string, autoIncrementIncrement int, autoIncrementOffset int) string {
	return fmt.Sprintf(
		"%s:%s@tcp(%s:%d)/%s?strict=true&clientFoundRows=true&autocommit=true&auto_increment_increment=%d&auto_increment_offset=%d&sql_mode=STRICT_ALL_TABLES",
		username, password, host, port, dbName, autoIncrementIncrement, autoIncrementOffset)
}
