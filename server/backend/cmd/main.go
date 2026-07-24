package main

import (
	"university-app/config"
	"university-app/server"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func main() {
	db := config.ConnectToDatabase()

	config.RunMigrations(db)

	server.StartServer(db)
}
