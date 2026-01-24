package handlers

import (
	"encoding/json"
	"net/http"
	"university-app/models"
	"university-app/repository"
)

type StudentHandler struct {
	repo *repository.StudentRepository
}

func NewStudentHandler(repo *repository.StudentRepository) *StudentHandler {
	return &StudentHandler{
		repo: repo,
	}
}

func (h *StudentHandler) ListStudents(w http.ResponseWriter, r *http.Request) {
	students, err := h.repo.GetAll(r.Context())
	if err != nil {
		http.Error(w, "Failed to fetch students", http.StatusInternalServerError)
		return
	}

	responses := make([]models.StudentResponse, len(students))
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
