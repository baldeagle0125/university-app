package handler

import (
	"encoding/json"
	"net/http"
	"strings"
	"time"
	appjwt "university-app/jwt"
	"university-app/model"
	"university-app/repository"

	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	studentRepo *repository.StudentRepository
	staffRepo   *repository.StaffRepository
	jwtSecret   string
}

func NewAuthHandler(studentRepo *repository.StudentRepository, staffRepo *repository.StaffRepository, jwtSecret string) *AuthHandler {
	return &AuthHandler{
		studentRepo: studentRepo,
		staffRepo:   staffRepo,
		jwtSecret:   jwtSecret,
	}
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	decoder := json.NewDecoder(r.Body)

	loginRequest := model.LoginRequest{}
	err := decoder.Decode(&loginRequest)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	student, err := h.studentRepo.GetByStudentNumber(r.Context(), loginRequest.StudentNumber)

	if err != nil || student == nil {
		http.Error(w, "Invalid student number or password", http.StatusUnauthorized)
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(student.PasswordHash), []byte(loginRequest.Password))
	if err != nil {
		http.Error(w, "Invalid student number or password", http.StatusUnauthorized)
		return
	}

	token, err := appjwt.GenerateStudentToken(h.jwtSecret, student.StudentNumber, student.ID, 7*24*time.Hour)
	if err != nil {
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	response := model.LoginResponse{Token: token}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func (h *AuthHandler) StaffLogin(w http.ResponseWriter, r *http.Request) {
	decoder := json.NewDecoder(r.Body)

	loginRequest := model.StaffLoginRequest{}
	err := decoder.Decode(&loginRequest)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	staffNumber := strings.TrimSpace(loginRequest.StaffNumber)
	password := strings.TrimSpace(loginRequest.Password)
	if staffNumber == "" || password == "" {
		http.Error(w, "staff_number and password are required", http.StatusBadRequest)
		return
	}

	staff, err := h.staffRepo.GetByStaffNumber(r.Context(), staffNumber)
	if err != nil || staff == nil {
		http.Error(w, "Invalid staff number or password", http.StatusUnauthorized)
		return
	}

	if !staff.IsActive {
		http.Error(w, "Staff account is inactive", http.StatusForbidden)
		return
	}

	err = bcrypt.CompareHashAndPassword([]byte(staff.PasswordHash), []byte(password))
	if err != nil {
		http.Error(w, "Invalid staff number or password", http.StatusUnauthorized)
		return
	}

	token, err := appjwt.GenerateStaffToken(h.jwtSecret, staff.StaffNumber, staff.ID, staff.Role, 7*24*time.Hour)
	if err != nil {
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	response := model.LoginResponse{Token: token}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
