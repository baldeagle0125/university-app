package handler

import (
	"encoding/json"
	"net/http"
	"strings"
	"university-app/jwt"
	"university-app/model"
	"university-app/repository"
)

type FeedbackHandler struct {
	repo      *repository.FeedbackRepository
	jwtSecret string
}

const maxJSONBodyBytes int64 = 1 << 20 // 1 MiB

func NewFeedbackHandler(repo *repository.FeedbackRepository, jwtSecret string) *FeedbackHandler {
	return &FeedbackHandler{
		repo:      repo,
		jwtSecret: jwtSecret,
	}
}

func (h *FeedbackHandler) CreateFeedback(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, maxJSONBodyBytes)

	var input model.CreateFeedbackInput
	if err = json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	if err = validateFeedbackInput(input); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	feedback, err := h.repo.CreateFeedbackEntry(r.Context(), studentNumber, input)
	if err != nil {
		http.Error(w, "Failed to create feedback", http.StatusInternalServerError)
		return
	}

	response := feedback.ToResponse()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func (h *FeedbackHandler) CreateTelemetryEvent(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, maxJSONBodyBytes)

	var input model.CreateTelemetryEventInput
	if err = json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	if err = validateTelemetryEventInput(input); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	event, err := h.repo.CreateTelemetryEvent(r.Context(), studentNumber, input)
	if err != nil {
		http.Error(w, "Failed to create telemetry event", http.StatusInternalServerError)
		return
	}

	response := event.ToResponse()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func (h *FeedbackHandler) ListFeedbackEntries(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	feedbackType := strings.TrimSpace(r.URL.Query().Get("feedback_type"))
	studentNumber := strings.TrimSpace(r.URL.Query().Get("student_number"))

	limit, offset, err := parseListPagination(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	entries, err := h.repo.ListFeedbackEntries(r.Context(), feedbackType, studentNumber, limit, offset)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch feedback entries")
		return
	}

	responses := make([]model.FeedbackResponse, len(entries))
	for i, entry := range entries {
		responses[i] = entry.ToResponse()
	}

	writeJSON(w, http.StatusOK, responses)
}

func (h *FeedbackHandler) ListTelemetryEvents(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	eventName := strings.TrimSpace(r.URL.Query().Get("event_name"))
	eventCategory := strings.TrimSpace(r.URL.Query().Get("event_category"))
	studentNumber := strings.TrimSpace(r.URL.Query().Get("student_number"))

	limit, offset, err := parseListPagination(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	events, err := h.repo.ListTelemetryEvents(r.Context(), eventName, eventCategory, studentNumber, limit, offset)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch telemetry events")
		return
	}

	responses := make([]model.TelemetryEventResponse, len(events))
	for i, event := range events {
		responses[i] = event.ToResponse()
	}

	writeJSON(w, http.StatusOK, responses)
}

func validateFeedbackInput(input model.CreateFeedbackInput) error {
	feedbackType := strings.TrimSpace(input.FeedbackType)
	if feedbackType != "bug" && feedbackType != "usability" && feedbackType != "feature" {
		return errBadRequest("Invalid feedback_type. Must be 'bug', 'usability', or 'feature'")
	}

	title := strings.TrimSpace(input.Title)
	message := strings.TrimSpace(input.Message)
	if title == "" {
		return errBadRequest("Title is required")
	}
	if message == "" {
		return errBadRequest("Message is required")
	}
	if len(title) > 120 {
		return errBadRequest("Title must be at most 120 characters")
	}
	if len(message) > 2000 {
		return errBadRequest("Message must be at most 2000 characters")
	}
	if len(strings.TrimSpace(input.AffectedArea)) > 80 {
		return errBadRequest("Affected area must be at most 80 characters")
	}

	if feedbackType == "usability" {
		if input.Rating == nil {
			return errBadRequest("Rating is required for usability feedback")
		}
		if *input.Rating < 1 || *input.Rating > 5 {
			return errBadRequest("Rating must be between 1 and 5")
		}
	} else if input.Rating != nil {
		return errBadRequest("Rating is only allowed for usability feedback")
	}

	return nil
}

func validateTelemetryEventInput(input model.CreateTelemetryEventInput) error {
	eventName := strings.TrimSpace(input.EventName)
	eventCategory := strings.TrimSpace(input.EventCategory)
	screenName := strings.TrimSpace(input.ScreenName)
	appVersion := strings.TrimSpace(input.AppVersion)

	if eventName == "" {
		return errBadRequest("event_name is required")
	}
	if eventCategory == "" {
		return errBadRequest("event_category is required")
	}
	if len(eventName) > 80 {
		return errBadRequest("event_name must be at most 80 characters")
	}
	if len(eventCategory) > 40 {
		return errBadRequest("event_category must be at most 40 characters")
	}
	if len(screenName) > 80 {
		return errBadRequest("screen_name must be at most 80 characters")
	}
	if len(appVersion) > 40 {
		return errBadRequest("app_version must be at most 40 characters")
	}

	return nil
}

type badRequestError struct {
	message string
}

func (e badRequestError) Error() string {
	return e.message
}

func errBadRequest(message string) error {
	return badRequestError{message: message}
}
