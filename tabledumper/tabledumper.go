package tabledumper

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"

	"database/sql"

	_ "github.com/lib/pq"
)

func dumpTable(rows *sql.Rows, out io.Writer) error {
	colNames, err := rows.Columns()
	if err != nil {
		panic(err)
	}
	writer := csv.NewWriter(out)
	writer.Comma = ';'

	readCols := make([]interface{}, len(colNames))
	writeCols := make([]*string, len(colNames))

	for i, _ := range writeCols {
		readCols[i] = &writeCols[i]
	}

	cols, _ := rows.Columns()
	writer.Write(cols)

	for rows.Next() {
		err := rows.Scan(readCols...)
		if err != nil {
			return err
		}

		values := make([]string, len(colNames))
		for i, _ := range writeCols {
			if writeCols[i] == nil {
				values[i] = ""
			} else {
				values[i] = *writeCols[i]
			}
		}

		writer.Write(values)
	}

	if err = rows.Err(); err != nil {
		return err
	}

	writer.Flush()
	return nil
}

func Dump(db *sql.DB, tablename, outputfile string) error {
	output, err := os.Create(outputfile)
	if err != nil {
		return err
	}
	defer output.Close()

	rows, err := db.Query(fmt.Sprintf("SELECT * from %s", tablename))
	if err != nil {
		return err
	}
	defer rows.Close()

	return dumpTable(rows, output)
}
