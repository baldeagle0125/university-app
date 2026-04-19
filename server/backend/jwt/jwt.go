package jwt

import (
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type Claims struct {
	PrincipalType string `json:"principal_type"`
	StudentNumber string `json:"student_number"`
	StudentID     int    `json:"student_id"`
	StaffNumber   string `json:"staff_number"`
	StaffID       int    `json:"staff_id"`
	Role          string `json:"role"`
	jwt.RegisteredClaims
}

func GenerateStudentToken(jwtSecret, studentNumber string, studentID int, ttl time.Duration) (string, error) {
	expiresAt := time.Now().Add(ttl)

	claims := &Claims{
		PrincipalType: "student",
		StudentNumber: studentNumber,
		StudentID:     studentID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(jwtSecret))
}

func GenerateStaffToken(jwtSecret, staffNumber string, staffID int, role string, ttl time.Duration) (string, error) {
	expiresAt := time.Now().Add(ttl)

	claims := &Claims{
		PrincipalType: "staff",
		StaffNumber:   staffNumber,
		StaffID:       staffID,
		Role:          role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(jwtSecret))
}

func ExtractStudentNumberFromRequest(r *http.Request, jwtSecret string) (string, error) {
	claims, err := extractClaimsFromRequest(r, jwtSecret)
	if err != nil {
		return "", err
	}

	if claims.PrincipalType != "" && claims.PrincipalType != "student" {
		return "", errors.New("token is not a student token")
	}

	if strings.TrimSpace(claims.StudentNumber) == "" {
		return "", errors.New("student_number missing in token")
	}

	return claims.StudentNumber, nil
}

func ExtractStaffFromRequest(r *http.Request, jwtSecret string) (staffNumber string, role string, err error) {
	claims, err := extractClaimsFromRequest(r, jwtSecret)
	if err != nil {
		return "", "", err
	}

	if claims.PrincipalType != "staff" {
		return "", "", errors.New("token is not a staff token")
	}

	if strings.TrimSpace(claims.StaffNumber) == "" {
		return "", "", errors.New("staff_number missing in token")
	}

	if strings.TrimSpace(claims.Role) == "" {
		return "", "", errors.New("role missing in token")
	}

	return claims.StaffNumber, claims.Role, nil
}

func extractClaimsFromRequest(r *http.Request, jwtSecret string) (*Claims, error) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return nil, errors.New("Authorization header missing")
	}

	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || parts[0] != "Bearer" {
		return nil, errors.New("Invalid Authorization header format")
	}

	tokenString := parts[1]

	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(jwtSecret), nil
	})
	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, errors.New("Invalid token")
	}

	return claims, nil
}
