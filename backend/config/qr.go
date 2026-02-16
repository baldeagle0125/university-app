package config

import (
	"log"
	"os"
	"strings"
)

func ReadQRSecretKey() string {
	secretKeyFile := "/run/secrets/qr-secret-key"

	if data, err := os.ReadFile(secretKeyFile); err == nil {
		return strings.TrimSpace(string(data))
	} else {
		log.Fatalf("Failed to read QR secret key from file: %v", err)
		return ""
	}
}
