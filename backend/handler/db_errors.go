package handler

import "strings"

func isUniqueViolation(err error) bool {
	errMessage := strings.ToLower(err.Error())
	return strings.Contains(errMessage, "duplicate key") || strings.Contains(errMessage, "unique constraint")
}
