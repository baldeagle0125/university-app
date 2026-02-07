package service

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"time"
)

type QRService struct {
	secretKey []byte
}

func NewQRService(secretKey []byte) *QRService {
	return &QRService{
		secretKey: secretKey,
	}
}

func (s *QRService) GenerateToken(studentNumber string) (string, time.Time, error) {
	expiresAt := time.Now().Add(2 * time.Minute)
	timestamp := expiresAt.Unix()

	payload := fmt.Sprintf("%s:%d", studentNumber, timestamp)

	h := hmac.New(sha256.New, s.secretKey)
	h.Write([]byte(payload))
	signature := base64.URLEncoding.EncodeToString(h.Sum(nil))

	token := fmt.Sprintf("%s:%s", payload, signature)

	return token, expiresAt, nil
}

func (s *QRService) VerifyToken(token string) (string, error) {
	// TODO
	return "", nil
}
