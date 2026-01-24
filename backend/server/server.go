package server

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func StartServer() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	routes(r)

	err := http.ListenAndServe(":3333", r)
	if err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
