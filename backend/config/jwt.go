package config

import (
	"log"
	"os"
	"strings"
)

func ReadJWTSecretKey() string {
	secretKeyFile := "/run/secrets/jwt-secret-key"

	if data, err := os.ReadFile(secretKeyFile); err == nil {
		return strings.TrimSpace(string(data))
	} else {
		log.Fatalf("Failed to read JWT secret key from file: %v", err)
		return ""
	}
}
