package server

import (
	"university-app/handlers"

	"github.com/go-chi/chi/v5"
)

func routes(r *chi.Mux) {
	r.Get("/api/v1/health", handlers.HealthEndpointHandler)
	r.Post("/api/v1/students", handlers.CreateStudentHandler)
	r.Get("/api/v1/students", handlers.GetStudentsHandler)
	r.Get("/api/v1/students/{id}", handlers.GetStudentByIDHandler)
	r.Put("/api/v1/students/{id}", handlers.UpdateStudentHandler)
	r.Patch("/api/v1/students/{id}", handlers.PartialUpdateStudentHandler)
	r.Delete("/api/v1/students/{id}", handlers.DeleteStudentHandler)
}
