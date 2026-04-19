package handler

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"university-app/model"
	"university-app/repository"

	"github.com/go-chi/chi/v5"
	"golang.org/x/crypto/bcrypt"
)

type StaffHandler struct {
	repo      *repository.StaffRepository
	jwtSecret string
}

func NewStaffHandler(repo *repository.StaffRepository, jwtSecret string) *StaffHandler {
	return &StaffHandler{
		repo:      repo,
		jwtSecret: jwtSecret,
	}
}

func (h *StaffHandler) ListStaff(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	role := strings.ToLower(strings.TrimSpace(r.URL.Query().Get("role")))
	if role != "" && role != "admin" && role != "staff" {
		writeError(w, http.StatusBadRequest, "role must be one of: admin, staff")
		return
	}

	var isActive *bool
	if isActiveRaw := strings.TrimSpace(r.URL.Query().Get("is_active")); isActiveRaw != "" {
		parsedIsActive, parseErr := strconv.ParseBool(isActiveRaw)
		if parseErr != nil {
			writeError(w, http.StatusBadRequest, "is_active must be true or false")
			return
		}

		isActive = &parsedIsActive
	}

	limit, offset, err := parseListPagination(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	staffList, err := h.repo.List(r.Context(), role, isActive, limit, offset)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch staff")
		return
	}

	responses := make([]model.StaffResponse, len(staffList))
	for i, staff := range staffList {
		responses[i] = staff.ToResponse()
	}

	writeJSON(w, http.StatusOK, responses)
}

func (h *StaffHandler) CreateStaff(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	var input model.CreateStaffInput
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err = decoder.Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	staff, err := buildCreateStaff(input)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	created, err := h.repo.Create(r.Context(), staff)
	if err != nil {
		if isUniqueViolation(err) {
			writeError(w, http.StatusConflict, "Staff with the same staff number or email already exists")
			return
		}

		writeError(w, http.StatusInternalServerError, "Failed to create staff")
		return
	}

	writeJSON(w, http.StatusCreated, created.ToResponse())
}

func (h *StaffHandler) UpdateStaff(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	id, err := parseStaffID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid staff ID")
		return
	}

	existingStaff, err := h.repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch staff")
		return
	}

	if existingStaff == nil {
		writeError(w, http.StatusNotFound, "Staff not found")
		return
	}

	var input model.UpdateStaffInput
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err = decoder.Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	updatedStaff, err := buildUpdateStaff(*existingStaff, input)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	staff, err := h.repo.UpdateByID(r.Context(), id, updatedStaff)
	if err != nil {
		if isUniqueViolation(err) {
			writeError(w, http.StatusConflict, "Staff with the same email already exists")
			return
		}

		writeError(w, http.StatusInternalServerError, "Failed to update staff")
		return
	}

	if staff == nil {
		writeError(w, http.StatusNotFound, "Staff not found")
		return
	}

	writeJSON(w, http.StatusOK, staff.ToResponse())
}

func parseStaffID(r *http.Request) (int, error) {
	idStr := chi.URLParam(r, "id")
	return strconv.Atoi(idStr)
}

func buildCreateStaff(input model.CreateStaffInput) (model.Staff, error) {
	staffNumber := strings.TrimSpace(input.StaffNumber)
	if staffNumber == "" {
		return model.Staff{}, errBadRequest("staff_number is required")
	}

	firstName := strings.TrimSpace(input.FirstName)
	if firstName == "" {
		return model.Staff{}, errBadRequest("first_name is required")
	}

	lastName := strings.TrimSpace(input.LastName)
	if lastName == "" {
		return model.Staff{}, errBadRequest("last_name is required")
	}

	email := strings.TrimSpace(input.Email)
	if email == "" {
		return model.Staff{}, errBadRequest("email is required")
	}

	password := strings.TrimSpace(input.Password)
	if password == "" {
		return model.Staff{}, errBadRequest("password is required")
	}

	role := strings.ToLower(strings.TrimSpace(input.Role))
	if role == "" {
		role = "staff"
	}

	if role != "admin" && role != "staff" {
		return model.Staff{}, errBadRequest("role must be one of: admin, staff")
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return model.Staff{}, err
	}

	return model.Staff{
		StaffNumber:  staffNumber,
		FirstName:    firstName,
		LastName:     lastName,
		Email:        email,
		PasswordHash: string(passwordHash),
		Role:         role,
		IsActive:     true,
	}, nil
}

func buildUpdateStaff(existingStaff model.Staff, input model.UpdateStaffInput) (model.Staff, error) {
	updatedStaff := existingStaff

	if input.FirstName != nil {
		firstName := strings.TrimSpace(*input.FirstName)
		if firstName == "" {
			return model.Staff{}, errBadRequest("first_name cannot be empty")
		}

		updatedStaff.FirstName = firstName
	}

	if input.LastName != nil {
		lastName := strings.TrimSpace(*input.LastName)
		if lastName == "" {
			return model.Staff{}, errBadRequest("last_name cannot be empty")
		}

		updatedStaff.LastName = lastName
	}

	if input.Email != nil {
		email := strings.TrimSpace(*input.Email)
		if email == "" {
			return model.Staff{}, errBadRequest("email cannot be empty")
		}

		updatedStaff.Email = email
	}

	if input.Password != nil {
		password := strings.TrimSpace(*input.Password)
		if password == "" {
			return model.Staff{}, errBadRequest("password cannot be empty")
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			return model.Staff{}, err
		}

		updatedStaff.PasswordHash = string(hashedPassword)
	}

	if input.Role != nil {
		role := strings.ToLower(strings.TrimSpace(*input.Role))
		if role != "admin" && role != "staff" {
			return model.Staff{}, errBadRequest("role must be one of: admin, staff")
		}

		updatedStaff.Role = role
	}

	if input.IsActive != nil {
		updatedStaff.IsActive = *input.IsActive
	}

	return updatedStaff, nil
}
