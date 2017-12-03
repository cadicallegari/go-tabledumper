// +build integration

package tabledumper_test

import (
	"testing"

	"database/sql"

	_ "github.com/lib/pq"
	"tabledumper/tabledumper"
)

func connect() (*sql.DB, error) {
	return sql.Open(
		"postgres",
		"postgresql://postgres:postgrespasswd@db/dumper_test?sslmode=disable",
	)
}

func TestBla(t *testing.T) {
	db, err := connect()
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	defer func() {
		_, err = db.Exec("TRUNCATE TABLE users")
		if err != nil {
			t.Fatal(err)
		}
	}()

	_, err = db.Exec(
		"INSERT INTO users (name, age, score) VALUES " +
			"('clark', 45, 8.5)," +
			"('wilson', 25, 9.2)," +
			"('pinoquio', 25, 10.0);",
	)
	if err != nil {
		t.Fatal(err)
	}

	err = tabledumper.Dump(db, "users", "/tmp/output.csv")
	if err != nil {
		t.Fatal(err)
	}

}
