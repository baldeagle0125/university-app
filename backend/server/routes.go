package server

import (
	"database/sql"
	"net/http"
	"os"
	"path/filepath"
	"strings"
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
	r.HandleFunc("/admin", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/admin/", http.StatusPermanentRedirect)
	})
	r.HandleFunc("/admin/*", adminPortalHandler("app/static/admin"))

	studentRepo := repository.NewStudentRepository(db)
	staffRepo := repository.NewStaffRepository(db)

	studentHandler := handler.NewStudentHandler(studentRepo, jwtSecret)
	r.Post("/api/v1/students", studentHandler.CreateStudent)
	r.Get("/api/v1/students", studentHandler.ListStudents)
	r.Get("/api/v1/students/{id}", studentHandler.GetStudentByID)
	r.Put("/api/v1/students/{id}", studentHandler.UpdateStudent)
	r.Patch("/api/v1/students/{id}", studentHandler.PartialUpdateStudent)
	r.Delete("/api/v1/students/{id}", studentHandler.DeleteStudent)
	r.Get("/api/v1/student-info", studentHandler.GetStudentByStudentNumber)

	authHandler := handler.NewAuthHandler(studentRepo, staffRepo, jwtSecret)
	staffHandler := handler.NewStaffHandler(staffRepo, jwtSecret)
	r.Post("/api/v1/login", authHandler.Login)
	r.Post("/api/v1/staff/login", authHandler.StaffLogin)

	qrService := service.NewQRService([]byte(qrSecret))
	qrHandler := handler.NewQRHandler(qrService, jwtSecret)
	r.Get("/api/v1/qr-code", qrHandler.GenerateQRCode)
	r.Get("/api/v1/barcode", qrHandler.GenerateBarcode)
	r.Post("/api/v1/verify", qrHandler.VerifyCode)

	cardRequestRepo := repository.NewCardRequestRepository(db)
	feedbackRepo := repository.NewFeedbackRepository(db)

	cardHandler := handler.NewCardHandler(cardRequestRepo, jwtSecret)
	feedbackHandler := handler.NewFeedbackHandler(feedbackRepo, jwtSecret)
	r.Post("/api/v1/card/requests", cardHandler.CreateCardRequest)
	r.Get("/api/v1/card/requests", cardHandler.GetCardRequests)
	r.Get("/api/v1/card/status", cardHandler.GetCardRequestStatus)
	r.Post("/api/v1/feedback", feedbackHandler.CreateFeedback)
	r.Post("/api/v1/telemetry/events", feedbackHandler.CreateTelemetryEvent)

	assignmentRepo := repository.NewAssignmentRepository(db)
	assignmentHandler := handler.NewAssignmentHandler(assignmentRepo, jwtSecret)
	r.Get("/api/v1/assignments", assignmentHandler.ListAssignments)
	r.Get("/api/v1/assignments/{id}", assignmentHandler.GetAssignment)
	r.Post("/api/v1/assignments/{id}/submit", assignmentHandler.SubmitAssignment)

	r.Get("/api/v1/admin/card-requests", cardHandler.GetPendingCardRequests)
	r.Post("/api/v1/admin/card-requests/{id}/process", cardHandler.ProcessCardRequest)
	r.Get("/api/v1/admin/assignments", assignmentHandler.ListAssignmentsForAdmin)
	r.Get("/api/v1/admin/feedback", feedbackHandler.ListFeedbackEntries)
	r.Get("/api/v1/admin/telemetry/events", feedbackHandler.ListTelemetryEvents)
	r.Get("/api/v1/admin/staff", staffHandler.ListStaff)
	r.Post("/api/v1/admin/staff", staffHandler.CreateStaff)
	r.Patch("/api/v1/admin/staff/{id}", staffHandler.UpdateStaff)
}

func adminPortalHandler(adminRoot string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		relativePath := strings.TrimPrefix(r.URL.Path, "/admin/")
		if relativePath == "" {
			http.ServeFile(w, r, filepath.Join(adminRoot, "index.html"))
			return
		}

		if strings.Contains(relativePath, "..") {
			http.ServeFile(w, r, filepath.Join(adminRoot, "index.html"))
			return
		}

		filePath := filepath.Join(adminRoot, filepath.Clean(relativePath))
		if info, err := os.Stat(filePath); err == nil && !info.IsDir() {
			http.ServeFile(w, r, filePath)
			return
		}

		http.ServeFile(w, r, filepath.Join(adminRoot, "index.html"))
	}
}
