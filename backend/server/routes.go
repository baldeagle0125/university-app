package server

import (
	"database/sql"
	"university-app/handler"
	"university-app/repository"

	"github.com/go-chi/chi/v5"
)

func routes(r *chi.Mux, db *sql.DB) {
	r.Get("/api/v1/health", handler.HealthEndpointHandler)

	studentRepo := repository.NewStudentRepository(db)

	studentHandler := handler.NewStudentHandler(studentRepo)
	r.Post("/api/v1/students", studentHandler.CreateStudent)
	r.Get("/api/v1/students", studentHandler.ListStudents)
	r.Get("/api/v1/students/{id}", studentHandler.GetStudentByID)
	r.Put("/api/v1/students/{id}", studentHandler.UpdateStudent)
	r.Patch("/api/v1/students/{id}", studentHandler.PartialUpdateStudent)
	r.Delete("/api/v1/students/{id}", studentHandler.DeleteStudent)
}
