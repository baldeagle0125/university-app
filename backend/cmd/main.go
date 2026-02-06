package main

import (
	"fmt"
	"university-app/config"
	"university-app/server"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func main() {
	fmt.Println("This is the University App server application.")

	db := config.ConnectToDatabase()

	config.RunMigrations(db)

	server.StartServer(db)
}
