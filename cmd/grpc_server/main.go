package main

import (
	"context"
	"database/sql"
	"log"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/brianvoe/gofakeit/v7"
	"github.com/jackc/pgx/v4/pgxpool"
)

const (
	dbDSN = "host=localhost port=54323 dbname=auth user=auth-user password=auth-password sslmode=disable"
)

func main() {
	ctx := context.Background()

	//Create a database connection pool
	pool, err := pgxpool.Connect(ctx, dbDSN)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}

	defer pool.Close()

	// Create a query to insert a record into the auth_user table
	builderInsert := sq.Insert("auth_user").
		PlaceholderFormat(sq.Dollar).
		Columns("name", "body").
		Values(gofakeit.Name(), gofakeit.Email()).
		Suffix("RETURNING id")
	query, args, err := builderInsert.ToSql()
	if err != nil {
		log.Fatalf("failed to build query: %v", err)
	}

	var noteID int
	err = pool.QueryRow(ctx, query, args...).Scan(&noteID)
	if err != nil {
		log.Fatalf("failed to insert note: %v", err)
	}

	log.Printf("inserted note with id: %d", noteID)

	// Create a query to select records from the auth_user table
	builderSelect := sq.Select("id", "name", "body", "created_at", "updated_at").
		From("auth_user").
		PlaceholderFormat(sq.Dollar).
		OrderBy("id ASC").
		Limit(10)
	query, args, err = builderSelect.ToSql()
	if err != nil {
		log.Fatalf("failed to build query: %v", err)
	}
	rows, err := pool.Query(ctx, query, args...)
	if err != nil {
		log.Fatalf("failed to select notes: %v", err)
	}

	var id int
	var name, body string
	var createdAt time.Time
	var updatedAt sql.NullTime

	for rows.Next() {
		err = rows.Scan(&id, &name, &body, &createdAt, &updatedAt)
		if err != nil {
			log.Fatalf("failed to scan note: %v", err)
		}
		log.Printf("id: %d, name: %s, body: %s, created_at: %v, updated_at: %v", id, name, body, createdAt, updatedAt)
	}

	// Create a query to update a record in the auth_user table
	builderUpdate := sq.Update("auth_user").
		PlaceholderFormat(sq.Dollar).
		Set("name", gofakeit.Name()).
		Set("body", gofakeit.Email()).
		Set("updated_at", time.Now()).
		Where(sq.Eq{"id": noteID})
	query, args, err = builderUpdate.ToSql()
	if err != nil {
		log.Fatalf("failed to build query: %v", err)
	}
	res, err := pool.Exec(ctx, query, args...)
	if err != nil {
		log.Fatalf("failed to update note: %v", err)
	}

	log.Printf("updated %d rows", res.RowsAffected())

	// Create a query to get the modified record from the table auth_user
	builderSelectOne := sq.Select("id", "name", "body", "created_at", "updated_at").
		From("auth_user").
		PlaceholderFormat(sq.Dollar).
		Where(sq.Eq{"id": noteID}).
		Limit(1)

	query, args, err = builderSelectOne.ToSql()
	if err != nil {
		log.Fatalf("failed to build query: %v", err)
	}
	err = pool.QueryRow(ctx, query, args...).Scan(&id, &name, &body, &createdAt, &updatedAt)
	if err != nil {
		log.Fatalf("failed to select notes: %v", err)
	}

	log.Printf("id: %d, name: %s, body: %s, created_at: %v, updated_at: %v", id, name, body, createdAt, updatedAt)

}
