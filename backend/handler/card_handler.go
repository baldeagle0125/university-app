package handler

import (
	"encoding/json"
	"net/http"
	"strconv"
	"university-app/jwt"
	"university-app/model"
	"university-app/repository"

	"github.com/go-chi/chi/v5"
)

type CardHandler struct {
	repo      *repository.CardRequestRepository
	jwtSecret string
}

func NewCardHandler(repo *repository.CardRequestRepository, jwtSecret string) *CardHandler {
	return &CardHandler{
		repo:      repo,
		jwtSecret: jwtSecret,
	}
}

func (h *CardHandler) CreateCardRequest(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var input model.CreateCardRequestInput
	err = json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	if input.RequestType != "new" && input.RequestType != "replacement" && input.RequestType != "lost" {
		http.Error(w, "Invalid request type. Must be 'new', 'replacement', or 'lost'", http.StatusBadRequest)
		return
	}

	latestRequest, err := h.repo.GetLatestCardRequestByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		http.Error(w, "Failed to check existing card requests", http.StatusInternalServerError)
		return
	}

	if latestRequest != nil && latestRequest.RequestStatus == "pending" {
		http.Error(w, "You already have a pending card request", http.StatusBadRequest)
		return
	}

	cardRequest, err := h.repo.CreateCardRequest(r.Context(), studentNumber, input.RequestType, input.RequestReason)
	if err != nil {
		http.Error(w, "Failed to create card request", http.StatusInternalServerError)
		return
	}

	if input.RequestType == "lost" {
		err = h.repo.UpdateStudentCardStatus(r.Context(), studentNumber, "lost")
		if err != nil {

		}
	}

	response := cardRequest.ToResponse()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func (h *CardHandler) GetCardRequests(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	cardRequests, err := h.repo.GetCardRequestsByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		http.Error(w, "Failed to fetch card requests", http.StatusInternalServerError)
		return
	}

	responses := make([]model.CardRequestResponse, len(cardRequests))
	for i, req := range cardRequests {
		responses[i] = req.ToResponse()
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(responses)
}

func (h *CardHandler) GetCardRequestStatus(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	latestRequest, err := h.repo.GetLatestCardRequestByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		http.Error(w, "Failed to fetch card request status", http.StatusInternalServerError)
		return
	}

	if latestRequest == nil {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"has_request": false,
			"message":     "No card requests found",
		})
		return
	}

	response := latestRequest.ToResponse()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"has_request": true,
		"request":     response,
	})
}

func (h *CardHandler) GetPendingCardRequests(w http.ResponseWriter, r *http.Request) {
	// TODO: Add admin authentication check
	_, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	cardRequests, err := h.repo.GetPendingCardRequests(r.Context())
	if err != nil {
		http.Error(w, "Failed to fetch pending card requests", http.StatusInternalServerError)
		return
	}

	responses := make([]model.CardRequestResponse, len(cardRequests))
	for i, cr := range cardRequests {
		responses[i] = cr.ToResponse()
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(responses)
}

func (h *CardHandler) ProcessCardRequest(w http.ResponseWriter, r *http.Request) {
	// TODO: Add admin authentication check
	adminNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid card request ID", http.StatusBadRequest)
		return
	}

	var input model.ProcessCardRequest
	err = json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	if input.RequestStatus != "approved" && input.RequestStatus != "rejected" {
		http.Error(w, "Invalid request status. Must be 'approved' or 'rejected'", http.StatusBadRequest)
		return
	}

	cardRequest, err := h.repo.GetCardRequestByID(r.Context(), id)
	if err != nil {
		http.Error(w, "Failed to fetch card request", http.StatusInternalServerError)
		return
	}
	if cardRequest == nil {
		http.Error(w, "Card request not found", http.StatusNotFound)
		return
	}

	if cardRequest.RequestStatus != "pending" {
		http.Error(w, "Card request has already been processed", http.StatusConflict)
		return
	}

	// Temporary using student number in lieu of admin number until we implement proper admin authentication
	updateRequest, err := h.repo.ProcessCardRequest(r.Context(), id, input.RequestStatus, adminNumber, input.AdminNotes)
	if err != nil {
		http.Error(w, "Failed to process card request", http.StatusInternalServerError)
		return
	}

	if input.RequestStatus == "approved" {
		err = h.repo.UpdateStudentCardStatus(r.Context(), cardRequest.StudentNumber, "active")
		if err != nil {

		}
	}

	response := updateRequest.ToResponse()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
