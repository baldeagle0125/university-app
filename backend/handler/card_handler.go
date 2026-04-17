package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"
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
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	var input model.CreateCardRequestInput
	err = json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if input.RequestType != "new" && input.RequestType != "replacement" && input.RequestType != "lost" {
		writeError(w, http.StatusBadRequest, "Invalid request type. Must be 'new', 'replacement', or 'lost'")
		return
	}

	latestRequest, err := h.repo.GetLatestCardRequestByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to check existing card requests")
		return
	}

	if latestRequest != nil && latestRequest.RequestStatus == "pending" {
		writeError(w, http.StatusBadRequest, "You already have a pending card request")
		return
	}

	cardRequest, err := h.repo.CreateCardRequest(r.Context(), studentNumber, input.RequestType, input.RequestReason)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to create card request")
		return
	}

	if input.RequestType == "lost" {
		err = h.repo.UpdateStudentCardStatus(r.Context(), studentNumber, "lost")
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Failed to update student card status")
			return
		}
	}

	response := cardRequest.ToResponse()
	writeJSON(w, http.StatusCreated, response)
}

func (h *CardHandler) GetCardRequests(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	cardRequests, err := h.repo.GetCardRequestsByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch card requests")
		return
	}

	responses := make([]model.CardRequestResponse, len(cardRequests))
	for i, req := range cardRequests {
		responses[i] = req.ToResponse()
	}

	writeJSON(w, http.StatusOK, responses)
}

func (h *CardHandler) GetCardRequestStatus(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	latestRequest, err := h.repo.GetLatestCardRequestByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch card request status")
		return
	}

	if latestRequest != nil && latestRequest.RequestStatus == "pending" {
		response := latestRequest.ToResponse()
		writeJSON(w, http.StatusOK, map[string]any{
			"has_request": true,
			"request":     response,
		})
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"has_request": false,
	})
}

func (h *CardHandler) GetPendingCardRequests(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := h.requireAdminStaffNumber(r)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	cardRequests, err := h.repo.GetPendingCardRequests(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch pending card requests")
		return
	}

	responses := make([]model.CardRequestResponse, len(cardRequests))
	for i, cr := range cardRequests {
		responses[i] = cr.ToResponse()
	}

	writeJSON(w, http.StatusOK, responses)
}

func (h *CardHandler) ProcessCardRequest(w http.ResponseWriter, r *http.Request) {
	adminNumber, statusCode, err := h.requireAdminStaffNumber(r)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	idStr := chi.URLParam(r, "id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid card request ID")
		return
	}

	var input model.ProcessCardRequest
	err = json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if input.RequestStatus != "approved" && input.RequestStatus != "rejected" {
		writeError(w, http.StatusBadRequest, "Invalid request status. Must be 'approved' or 'rejected'")
		return
	}

	cardRequest, err := h.repo.GetCardRequestByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch card request")
		return
	}
	if cardRequest == nil {
		writeError(w, http.StatusNotFound, "Card request not found")
		return
	}

	if cardRequest.RequestStatus != "pending" {
		writeError(w, http.StatusConflict, "Card request has already been processed")
		return
	}

	updateRequest, err := h.repo.ProcessCardRequest(r.Context(), id, input.RequestStatus, adminNumber, input.AdminNotes)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to process card request")
		return
	}

	if input.RequestStatus == "approved" {
		err = h.repo.UpdateStudentCardStatus(r.Context(), cardRequest.StudentNumber, "active")
		if err != nil {
			writeError(w, http.StatusInternalServerError, "Failed to update student card status")
			return
		}
	}

	response := updateRequest.ToResponse()
	writeJSON(w, http.StatusOK, response)
}

func (h *CardHandler) requireAdminStaffNumber(r *http.Request) (string, int, error) {
	staffNumber, role, err := jwt.ExtractStaffFromRequest(r, h.jwtSecret)
	if err != nil {
		return "", http.StatusUnauthorized, err
	}

	if strings.ToLower(role) != "admin" {
		return "", http.StatusForbidden, errors.New("staff role is not admin")
	}

	return staffNumber, http.StatusOK, nil
}
