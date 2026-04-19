package handler

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"
	"university-app/jwt"
	"university-app/model"
	"university-app/repository"

	"github.com/go-chi/chi/v5"
	"golang.org/x/crypto/bcrypt"
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
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	search := strings.TrimSpace(r.URL.Query().Get("search"))
	cardStatus := strings.TrimSpace(r.URL.Query().Get("card_status"))
	programCode := strings.TrimSpace(r.URL.Query().Get("program_code"))

	if cardStatus != "" && !isValidCardStatus(cardStatus) {
		writeError(w, http.StatusBadRequest, "card_status must be one of: active, expired, lost, requested, none")
		return
	}

	limit, offset, err := parseListPagination(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	students, err := h.repo.GetAll(r.Context(), search, cardStatus, programCode, limit, offset)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch students")
		return
	}

	responses := make([]model.StudentResponse, len(students))
	for i, student := range students {
		responses[i] = student.ToResponse()
	}

	writeJSON(w, http.StatusOK, responses)
}

func (h *StudentHandler) CreateStudent(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	var input model.CreateStudentInput
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err = decoder.Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	student, err := buildCreateStudent(input)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	created, err := h.repo.Create(r.Context(), student)
	if err != nil {
		if isUniqueViolation(err) {
			writeError(w, http.StatusConflict, "Student with the same student number or email already exists")
			return
		}

		writeError(w, http.StatusInternalServerError, "Failed to create student")
		return
	}

	writeJSON(w, http.StatusCreated, created.ToResponse())
}

func (h *StudentHandler) GetStudentByID(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	id, err := parseStudentID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid student ID")
		return
	}

	student, err := h.repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch student")
		return
	}

	if student == nil {
		writeError(w, http.StatusNotFound, "Student not found")
		return
	}

	writeJSON(w, http.StatusOK, student.ToResponse())
}

func (h *StudentHandler) UpdateStudent(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	id, err := parseStudentID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid student ID")
		return
	}

	existingStudent, err := h.repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch student")
		return
	}

	if existingStudent == nil {
		writeError(w, http.StatusNotFound, "Student not found")
		return
	}

	var input model.UpdateStudentInput
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	updatedStudent, err := buildUpdateStudent(*existingStudent, input)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	student, err := h.repo.UpdateByID(r.Context(), id, updatedStudent)
	if err != nil {
		if isUniqueViolation(err) {
			writeError(w, http.StatusConflict, "Student with the same student number or email already exists")
			return
		}

		writeError(w, http.StatusInternalServerError, "Failed to update student")
		return
	}

	if student == nil {
		writeError(w, http.StatusNotFound, "Student not found")
		return
	}

	writeJSON(w, http.StatusOK, student.ToResponse())
}

func (h *StudentHandler) PartialUpdateStudent(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	id, err := parseStudentID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid student ID")
		return
	}

	existingStudent, err := h.repo.GetByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch student")
		return
	}

	if existingStudent == nil {
		writeError(w, http.StatusNotFound, "Student not found")
		return
	}

	var input model.PartialUpdateStudentInput
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if !input.HasUpdates() {
		writeError(w, http.StatusBadRequest, "No fields provided for update")
		return
	}

	updatedStudent, err := applyPartialUpdate(*existingStudent, input)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	student, err := h.repo.UpdateByID(r.Context(), id, updatedStudent)
	if err != nil {
		if isUniqueViolation(err) {
			writeError(w, http.StatusConflict, "Student with the same student number or email already exists")
			return
		}

		writeError(w, http.StatusInternalServerError, "Failed to update student")
		return
	}

	if student == nil {
		writeError(w, http.StatusNotFound, "Student not found")
		return
	}

	writeJSON(w, http.StatusOK, student.ToResponse())
}

func (h *StudentHandler) DeleteStudent(w http.ResponseWriter, r *http.Request) {
	_, statusCode, err := requireAdminStaffNumber(r, h.jwtSecret)
	if err != nil {
		if statusCode == http.StatusUnauthorized {
			writeError(w, http.StatusUnauthorized, "Unauthorized")
			return
		}

		writeError(w, http.StatusForbidden, "Forbidden")
		return
	}

	id, err := parseStudentID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "Invalid student ID")
		return
	}

	deleted, err := h.repo.DeleteByID(r.Context(), id)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to delete student")
		return
	}

	if !deleted {
		writeError(w, http.StatusNotFound, "Student not found")
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *StudentHandler) GetStudentByStudentNumber(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	student, err := h.repo.GetByStudentNumber(r.Context(), studentNumber)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to fetch student")
		return
	}

	if student == nil {
		writeError(w, http.StatusNotFound, "Student not found")
		return
	}

	response := student.ToResponse()
	writeJSON(w, http.StatusOK, response)
}

func parseStudentID(r *http.Request) (int, error) {
	idStr := chi.URLParam(r, "id")
	return strconv.Atoi(idStr)
}

func buildCreateStudent(input model.CreateStudentInput) (model.Student, error) {
	studentNumber := strings.TrimSpace(input.StudentNumber)
	if studentNumber == "" {
		return model.Student{}, errBadRequest("student_number is required")
	}

	firstName := strings.TrimSpace(input.FirstName)
	if firstName == "" {
		return model.Student{}, errBadRequest("first_name is required")
	}

	lastName := strings.TrimSpace(input.LastName)
	if lastName == "" {
		return model.Student{}, errBadRequest("last_name is required")
	}

	email := strings.TrimSpace(input.Email)
	if email == "" {
		return model.Student{}, errBadRequest("email is required")
	}

	password := strings.TrimSpace(input.Password)
	if password == "" {
		return model.Student{}, errBadRequest("password is required")
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return model.Student{}, err
	}

	dateOfBirth, err := parseOptionalDate(input.DateOfBirth)
	if err != nil {
		return model.Student{}, errBadRequest("date_of_birth must use YYYY-MM-DD format")
	}

	cardIssuedDate, err := parseOptionalDate(input.CardIssuedDate)
	if err != nil {
		return model.Student{}, errBadRequest("card_issued_date must use YYYY-MM-DD format")
	}

	cardExpiryDate, err := parseOptionalDate(input.CardExpiryDate)
	if err != nil {
		return model.Student{}, errBadRequest("card_expiry_date must use YYYY-MM-DD format")
	}

	cardStatus := strings.TrimSpace(input.CardStatus)
	if cardStatus == "" {
		cardStatus = "none"
	}

	if !isValidCardStatus(cardStatus) {
		return model.Student{}, errBadRequest("card_status must be one of: active, expired, lost, requested, none")
	}

	return model.Student{
		StudentNumber:   studentNumber,
		FirstName:       firstName,
		LastName:        lastName,
		Email:           email,
		PasswordHash:    string(passwordHash),
		ProgramCode:     toNullString(input.ProgramCode),
		CourseTitle:     toNullString(input.CourseTitle),
		DateOfBirth:     dateOfBirth,
		SUPosition:      toNullString(input.SUPosition),
		Memberships:     input.Memberships,
		CardIssuedDate:  cardIssuedDate,
		CardExpiryDate:  cardExpiryDate,
		ProfilePhotoURL: toNullString(input.ProfilePhotoURL),
		CardStatus:      cardStatus,
	}, nil
}

func buildUpdateStudent(existingStudent model.Student, input model.UpdateStudentInput) (model.Student, error) {
	studentNumber := strings.TrimSpace(input.StudentNumber)
	if studentNumber == "" {
		return model.Student{}, errBadRequest("student_number is required")
	}

	firstName := strings.TrimSpace(input.FirstName)
	if firstName == "" {
		return model.Student{}, errBadRequest("first_name is required")
	}

	lastName := strings.TrimSpace(input.LastName)
	if lastName == "" {
		return model.Student{}, errBadRequest("last_name is required")
	}

	email := strings.TrimSpace(input.Email)
	if email == "" {
		return model.Student{}, errBadRequest("email is required")
	}

	passwordHash := existingStudent.PasswordHash
	if strings.TrimSpace(input.Password) != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(strings.TrimSpace(input.Password)), bcrypt.DefaultCost)
		if err != nil {
			return model.Student{}, err
		}

		passwordHash = string(hashedPassword)
	}

	dateOfBirth, err := parseOptionalDate(input.DateOfBirth)
	if err != nil {
		return model.Student{}, errBadRequest("date_of_birth must use YYYY-MM-DD format")
	}

	cardIssuedDate, err := parseOptionalDate(input.CardIssuedDate)
	if err != nil {
		return model.Student{}, errBadRequest("card_issued_date must use YYYY-MM-DD format")
	}

	cardExpiryDate, err := parseOptionalDate(input.CardExpiryDate)
	if err != nil {
		return model.Student{}, errBadRequest("card_expiry_date must use YYYY-MM-DD format")
	}

	cardStatus := strings.TrimSpace(input.CardStatus)
	if cardStatus == "" {
		return model.Student{}, errBadRequest("card_status is required")
	}

	if !isValidCardStatus(cardStatus) {
		return model.Student{}, errBadRequest("card_status must be one of: active, expired, lost, requested, none")
	}

	return model.Student{
		ID:              existingStudent.ID,
		StudentNumber:   studentNumber,
		FirstName:       firstName,
		LastName:        lastName,
		Email:           email,
		PasswordHash:    passwordHash,
		ProgramCode:     toNullString(input.ProgramCode),
		CourseTitle:     toNullString(input.CourseTitle),
		DateOfBirth:     dateOfBirth,
		SUPosition:      toNullString(input.SUPosition),
		Memberships:     input.Memberships,
		CardIssuedDate:  cardIssuedDate,
		CardExpiryDate:  cardExpiryDate,
		ProfilePhotoURL: toNullString(input.ProfilePhotoURL),
		CardStatus:      cardStatus,
		CreatedAt:       existingStudent.CreatedAt,
		UpdatedAt:       existingStudent.UpdatedAt,
	}, nil
}

func applyPartialUpdate(existingStudent model.Student, input model.PartialUpdateStudentInput) (model.Student, error) {
	updatedStudent := existingStudent

	if input.StudentNumber != nil {
		studentNumber := strings.TrimSpace(*input.StudentNumber)
		if studentNumber == "" {
			return model.Student{}, errBadRequest("student_number cannot be empty")
		}

		updatedStudent.StudentNumber = studentNumber
	}

	if input.FirstName != nil {
		firstName := strings.TrimSpace(*input.FirstName)
		if firstName == "" {
			return model.Student{}, errBadRequest("first_name cannot be empty")
		}

		updatedStudent.FirstName = firstName
	}

	if input.LastName != nil {
		lastName := strings.TrimSpace(*input.LastName)
		if lastName == "" {
			return model.Student{}, errBadRequest("last_name cannot be empty")
		}

		updatedStudent.LastName = lastName
	}

	if input.Email != nil {
		email := strings.TrimSpace(*input.Email)
		if email == "" {
			return model.Student{}, errBadRequest("email cannot be empty")
		}

		updatedStudent.Email = email
	}

	if input.Password != nil {
		password := strings.TrimSpace(*input.Password)
		if password == "" {
			return model.Student{}, errBadRequest("password cannot be empty")
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
		if err != nil {
			return model.Student{}, err
		}

		updatedStudent.PasswordHash = string(hashedPassword)
	}

	if input.ProgramCode != nil {
		updatedStudent.ProgramCode = toNullString(input.ProgramCode)
	}

	if input.CourseTitle != nil {
		updatedStudent.CourseTitle = toNullString(input.CourseTitle)
	}

	if input.DateOfBirth != nil {
		dateOfBirth, err := parseOptionalDate(input.DateOfBirth)
		if err != nil {
			return model.Student{}, errBadRequest("date_of_birth must use YYYY-MM-DD format")
		}

		updatedStudent.DateOfBirth = dateOfBirth
	}

	if input.SUPosition != nil {
		updatedStudent.SUPosition = toNullString(input.SUPosition)
	}

	if input.Memberships != nil {
		updatedStudent.Memberships = *input.Memberships
	}

	if input.CardIssuedDate != nil {
		cardIssuedDate, err := parseOptionalDate(input.CardIssuedDate)
		if err != nil {
			return model.Student{}, errBadRequest("card_issued_date must use YYYY-MM-DD format")
		}

		updatedStudent.CardIssuedDate = cardIssuedDate
	}

	if input.CardExpiryDate != nil {
		cardExpiryDate, err := parseOptionalDate(input.CardExpiryDate)
		if err != nil {
			return model.Student{}, errBadRequest("card_expiry_date must use YYYY-MM-DD format")
		}

		updatedStudent.CardExpiryDate = cardExpiryDate
	}

	if input.ProfilePhotoURL != nil {
		updatedStudent.ProfilePhotoURL = toNullString(input.ProfilePhotoURL)
	}

	if input.CardStatus != nil {
		cardStatus := strings.TrimSpace(*input.CardStatus)
		if cardStatus == "" {
			return model.Student{}, errBadRequest("card_status cannot be empty")
		}

		if !isValidCardStatus(cardStatus) {
			return model.Student{}, errBadRequest("card_status must be one of: active, expired, lost, requested, none")
		}

		updatedStudent.CardStatus = cardStatus
	}

	return updatedStudent, nil
}

func parseOptionalDate(value *string) (sql.NullTime, error) {
	if value == nil {
		return sql.NullTime{}, nil
	}

	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return sql.NullTime{}, nil
	}

	parsedDate, err := time.Parse(time.DateOnly, trimmed)
	if err != nil {
		return sql.NullTime{}, err
	}

	return sql.NullTime{Time: parsedDate, Valid: true}, nil
}

func toNullString(value *string) sql.NullString {
	if value == nil {
		return sql.NullString{}
	}

	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return sql.NullString{}
	}

	return sql.NullString{String: trimmed, Valid: true}
}

func isValidCardStatus(cardStatus string) bool {
	allowedCardStatuses := map[string]struct{}{
		"active":    {},
		"expired":   {},
		"lost":      {},
		"requested": {},
		"none":      {},
	}

	_, ok := allowedCardStatuses[cardStatus]
	return ok
}
