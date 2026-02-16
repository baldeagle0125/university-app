package service

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"image/png"
	"strconv"
	"strings"
	"time"

	"github.com/boombuler/barcode"
	"github.com/boombuler/barcode/code128"
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

func (s *QRService) GenerateBarcodeToken(studentNumber string) (string, time.Time, error) {
	expiresAt := time.Now().Add(2 * time.Minute)
	timestamp := expiresAt.Unix()

	payload := fmt.Sprintf("%s%d", studentNumber, timestamp)

	h := hmac.New(sha256.New, s.secretKey)
	h.Write([]byte(payload))
	fullSignature := hex.EncodeToString(h.Sum(nil))

	signature := fullSignature[:40]

	token := fmt.Sprintf("%s%s", payload, signature)

	fmt.Printf("Generated barcode token: %s (length: %d)\n", token, len(token))

	return token, expiresAt, nil
}

func (s *QRService) GenerateBarcode(studentNumber string) ([]byte, time.Time, error) {
	token, expiresAt, err := s.GenerateBarcodeToken(studentNumber)
	if err != nil {
		return nil, time.Time{}, err
	}

	barcodeImage, err := code128.Encode(token)
	if err != nil {
		return nil, time.Time{}, err
	}

	scaledBarcode, err := barcode.Scale(barcodeImage, 800, 150)
	if err != nil {
		return nil, time.Time{}, err
	}

	var buf bytes.Buffer
	err = png.Encode(&buf, scaledBarcode)
	if err != nil {
		return nil, time.Time{}, err
	}
	
	return buf.Bytes(), expiresAt, nil
}

func (s *QRService) VerifyToken(token string) (string, error) {
	if strings.Contains(token, ":") {
		parts := strings.Split(token, ":")
		if len(parts) == 3 {
			studentNumber, err := s.VerifyQRToken(token)
			if err == nil {
				return studentNumber, nil
			}
		}
	}

	return s.VerifyBarcodeToken(token)
}

func (s *QRService) VerifyQRToken(token string) (string, error) {
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

func (s *QRService) VerifyBarcodeToken(token string) (string, error) {
	if len(token) < 50 {
		return "", errors.New("invalid token format")
	}

	signature := token[len(token)-40:]
	timestampStr := token[len(token)-50 : len(token)-40]
	studentNumber := token[:len(token)-50]

	timestamp, err := strconv.ParseInt(timestampStr, 10, 64)
	if err != nil {
		return "", errors.New("invalid timestamp")
	}

	expiresAt := time.Unix(timestamp, 0)
	if time.Now().After(expiresAt) {
		return "", errors.New("token has expired")
	}

	payload := fmt.Sprintf("%s%d", studentNumber, timestamp)
	h := hmac.New(sha256.New, s.secretKey)
	h.Write([]byte(payload))
	fullSignature := hex.EncodeToString(h.Sum(nil))
	expectedSignature := fullSignature[:40]

	if !hmac.Equal([]byte(signature), []byte(expectedSignature)) {
		return "", errors.New("invalid signature")
	}

	return studentNumber, nil
}
