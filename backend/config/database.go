package config

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/pressly/goose/v3"
)

func ConnectToDatabase() *sql.DB {
	connStr := getDatabaseURL()

	db, err := sql.Open("pgx", connStr)
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}

	if err := db.PingContext(context.Background()); err != nil {
		log.Fatalf("Failed to ping the database: %v", err)
	}

	log.Println("Successfully connected to the database.")
	return db
}

func getDatabaseURL() string {
	dbUser := os.Getenv("POSTGRES_USER")
	dbPassword := readPassword()
	dbHost := os.Getenv("POSTGRES_HOST")
	dbPort := os.Getenv("POSTGRES_PORT")
	dbName := os.Getenv("POSTGRES_DB")

	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", dbUser, dbPassword, dbHost, dbPort, dbName)
}

func readPassword() string {
	passwordFile := "/run/secrets/db-password"

	if data, err := os.ReadFile(passwordFile); err == nil {
		return strings.TrimSpace(string(data))
	} else {
		log.Fatalf("Failed to read database password from file: %v", err)
		return ""
	}
}

func RunMigrations(db *sql.DB) {
	err := goose.SetDialect("postgres")
	if err != nil {
		log.Fatalf("Failed to set goose dialect: %v", err)
	}

	err = goose.Up(db, "./migrations")
	if err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}

	log.Println("Database migrations applied successfully.")
}
