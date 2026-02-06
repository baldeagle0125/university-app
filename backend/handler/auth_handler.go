package handler

import (
	"encoding/json"
	"net/http"
	"time"
	"university-app/model"
	"university-app/repository"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	studentRepo *repository.StudentRepository
	jwtSecret   string
}

func NewAuthHandler(studentRepo *repository.StudentRepository, jwtSecret string) *AuthHandler {
	return &AuthHandler{
		studentRepo: studentRepo,
		jwtSecret:   jwtSecret,
	}
}

type Claims struct {
	StudentNumber string `json:"student_number"`
	StudentID     int    `json:"student_id"`
	jwt.RegisteredClaims
}

func (h *AuthHandler) generateToken(studentNumber string, studentID int) (string, error) {
	expirationTime := time.Now().Add(7 * 24 * time.Hour)

	claims := &Claims{
		StudentNumber: studentNumber,
		StudentID:     studentID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(h.jwtSecret))

	return tokenString, err
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

	token, err := h.generateToken(student.StudentNumber, student.ID)
	if err != nil {
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	response := model.LoginResponse{Token: token}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
