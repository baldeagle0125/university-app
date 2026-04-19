package handler

import (
	"errors"
	"net/http"
	"strings"
	"university-app/jwt"
)

func requireAdminStaffNumber(r *http.Request, jwtSecret string) (string, int, error) {
	staffNumber, role, err := jwt.ExtractStaffFromRequest(r, jwtSecret)
	if err != nil {
		return "", http.StatusUnauthorized, err
	}

	if strings.ToLower(role) != "admin" {
		return "", http.StatusForbidden, errors.New("staff role is not admin")
	}

	return staffNumber, http.StatusOK, nil
}
