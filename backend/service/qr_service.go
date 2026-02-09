package service

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"strconv"
	"strings"
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
	parts := strings.Split(token, ":")
	if len(parts) != 3 {
		return "", errors.New("invalid token format")
	}

	studentNumber := parts[0]
	timestampStr := parts[1]
	receivedSignature := parts[2]

	timestamp, err := strconv.ParseInt(timestampStr, 10, 64)
	if err != nil {
		return "", errors.New("invalid timestamp")
	}

	expiresAt := time.Unix(timestamp, 0)
	if time.Now().After(expiresAt) {
		return "", errors.New("token has expired")
	}

	payload := fmt.Sprintf("%s:%s", studentNumber, timestampStr)
	h := hmac.New(sha256.New, s.secretKey)
	h.Write([]byte(payload))
	expectedSignature := base64.URLEncoding.EncodeToString(h.Sum(nil))

	if !hmac.Equal([]byte(receivedSignature), []byte(expectedSignature)) {
		return "", errors.New("invalid signature")
	}

	return studentNumber, nil
}
