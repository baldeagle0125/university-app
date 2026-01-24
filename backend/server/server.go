package server

import (
	"database/sql"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func StartServer(db *sql.DB) {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	routes(r, db)

	log.Println("Server starting on :3333")
	err := http.ListenAndServe(":3333", r)
	if err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
