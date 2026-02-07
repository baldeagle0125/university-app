package service

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"time"

	"github.com/skip2/go-qrcode"
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

func (s *QRService) GenerateQRCode(studentNumber string) ([]byte, time.Time, error) {
	token, expiresAt, err := s.GenerateToken(studentNumber)
	if err != nil {
		return nil, time.Time{}, err
	}

	qrCode, err := qrcode.Encode(token, qrcode.Medium, 256)
	if err != nil {
		return nil, time.Time{}, err
	}

	return qrCode, expiresAt, nil
}

func (s *QRService) VerifyToken(token string) (string, error) {
	// TODO
	return "", nil
}
