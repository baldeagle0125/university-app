package handler

import (
	"encoding/json"
	"net/http"
	"university-app/jwt"
	"university-app/model"
	"university-app/repository"
)

type StudentHandler struct {
	repo      *repository.StudentRepository
	jwtSecret string
}

func NewStudentHandler(repo *repository.StudentRepository, jwtSecret string) *StudentHandler {
	return &StudentHandler{
		repo:      repo,
		jwtSecret: jwtSecret,
	}
}

func (h *StudentHandler) ListStudents(w http.ResponseWriter, r *http.Request) {
	students, err := h.repo.GetAll(r.Context())
	if err != nil {
		http.Error(w, "Failed to fetch students", http.StatusInternalServerError)
		return
	}

	responses := make([]model.StudentResponse, len(students))
	for i, student := range students {
		responses[i] = student.ToResponse()
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(responses)
}

func (h *StudentHandler) CreateStudent(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "Not implemented yet", http.StatusNotImplemented)
}

func (h *StudentHandler) GetStudentByID(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "Not implemented yet", http.StatusNotImplemented)
}

func (h *StudentHandler) UpdateStudent(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "Not implemented yet", http.StatusNotImplemented)
}

func (h *StudentHandler) PartialUpdateStudent(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "Not implemented yet", http.StatusNotImplemented)
}

func (h *StudentHandler) DeleteStudent(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "Not implemented yet", http.StatusNotImplemented)
}

func (h *StudentHandler) GetStudentByStudentID(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "Not implemented yet", http.StatusNotImplemented)
}

func (h *StudentHandler) GetStudentByStudentNumber(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	student, err := h.repo.GetByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		http.Error(w, "Failed to fetch student", http.StatusInternalServerError)
		return
	}

	if student == nil {
		http.Error(w, "Student not found", http.StatusNotFound)
		return
	}

	response := student.ToResponse()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
