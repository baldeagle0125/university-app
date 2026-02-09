package server

import (
	"database/sql"
	"net/http"
	"university-app/config"
	"university-app/handler"
	"university-app/repository"
	"university-app/service"

	"github.com/go-chi/chi/v5"
)

func routes(r *chi.Mux, db *sql.DB) {
	jwtSecret := config.ReadJWTSecretKey()
	qrSecret := config.ReadQRSecretKey()

	r.Get("/api/v1/health", handler.HealthEndpointHandler)

	fileServer := http.FileServer(http.Dir("app/static/profile-photos"))
	r.Handle("/static/profile-photos/*", http.StripPrefix("/static/profile-photos/", fileServer))

	studentRepo := repository.NewStudentRepository(db)

	studentHandler := handler.NewStudentHandler(studentRepo, jwtSecret)
	r.Post("/api/v1/students", studentHandler.CreateStudent)
	r.Get("/api/v1/students", studentHandler.ListStudents)
	r.Get("/api/v1/students/{id}", studentHandler.GetStudentByID)
	r.Put("/api/v1/students/{id}", studentHandler.UpdateStudent)
	r.Patch("/api/v1/students/{id}", studentHandler.PartialUpdateStudent)
	r.Delete("/api/v1/students/{id}", studentHandler.DeleteStudent)
	r.Get("/api/v1/student-info", studentHandler.GetStudentByStudentNumber)

	authHandler := handler.NewAuthHandler(studentRepo, jwtSecret)
	r.Post("/api/v1/login", authHandler.Login)

	qrService := service.NewQRService([]byte(qrSecret))
	qrHandler := handler.NewQRHandler(qrService, jwtSecret)
	r.Get("/api/v1/qr-code", qrHandler.GenerateQRCode)
}
