package handler

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"
	"university-app/jwt"
	"university-app/model"
	"university-app/repository"

	"github.com/go-chi/chi/v5"
)

type AssignmentHandler struct {
	repo      *repository.AssignmentRepository
	jwtSecret string
}

func NewAssignmentHandler(repo *repository.AssignmentRepository, jwtSecret string) *AssignmentHandler {
	return &AssignmentHandler{
		repo:      repo,
		jwtSecret: jwtSecret,
	}
}

func (h *AssignmentHandler) ListAssignments(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	assignments, err := h.repo.GetAssignmentsByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		http.Error(w, "Failed to fetch assignments", http.StatusInternalServerError)
		return
	}

	if len(assignments) == 0 {
		if err := h.repo.SeedDefaultAssignmentsForStudent(r.Context(), studentNumber); err != nil {
			http.Error(w, "Failed to initialize assignments", http.StatusInternalServerError)
			return
		}

		assignments, err = h.repo.GetAssignmentsByStudentNumber(r.Context(), studentNumber)
		if err != nil {
			http.Error(w, "Failed to fetch assignments", http.StatusInternalServerError)
			return
		}
	}

	now := time.Now().UTC()
	responses := make([]model.AssignmentResponse, len(assignments))
	for i, assignment := range assignments {
		responses[i] = assignment.ToResponse(now)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(responses)
}

func (h *AssignmentHandler) GetAssignment(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid assignment ID", http.StatusBadRequest)
		return
	}

	assignment, err := h.repo.GetAssignmentByIDAndStudentNumber(r.Context(), id, studentNumber)
	if err != nil {
		http.Error(w, "Failed to fetch assignment", http.StatusInternalServerError)
		return
	}
	if assignment == nil {
		http.Error(w, "Assignment not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(assignment.ToResponse(time.Now().UTC()))
}

func (h *AssignmentHandler) SubmitAssignment(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid assignment ID", http.StatusBadRequest)
		return
	}

	assignment, err := h.repo.GetAssignmentByIDAndStudentNumber(r.Context(), id, studentNumber)
	if err != nil {
		http.Error(w, "Failed to fetch assignment", http.StatusInternalServerError)
		return
	}
	if assignment == nil {
		http.Error(w, "Assignment not found", http.StatusNotFound)
		return
	}
	if assignment.IsSubmitted() {
		http.Error(w, "Assignment already submitted", http.StatusConflict)
		return
	}

	var input model.SubmitAssignmentInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	input.SubmissionText = strings.TrimSpace(input.SubmissionText)
	if input.SubmissionText == "" {
		http.Error(w, "Submission text is required", http.StatusBadRequest)
		return
	}

	updatedAssignment, err := h.repo.SubmitAssignment(r.Context(), id, studentNumber, input.SubmissionText)
	if err != nil {
		http.Error(w, "Failed to submit assignment", http.StatusInternalServerError)
		return
	}
	if updatedAssignment == nil {
		http.Error(w, "Assignment not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(updatedAssignment.ToResponse(time.Now().UTC()))
}
