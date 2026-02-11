package handler

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"time"
	"university-app/jwt"
	"university-app/service"
)

type QRHandler struct {
	qrService *service.QRService
	jwtSecret string
}

func NewQRHandler(qrService *service.QRService, jwtSecret string) *QRHandler {
	return &QRHandler{
		qrService: qrService,
		jwtSecret: jwtSecret,
	}
}

type CodeResponse struct {
	Code      string `json:"code"`
	ExpiresAt string `json:"expires_at"`
}

func (h *QRHandler) GenerateQRCode(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	qrImageBytes, expiresAt, err := h.qrService.GenerateQRCode(studentNumber)
	if err != nil {
		http.Error(w, "Failed to generate QR code", http.StatusInternalServerError)
		return
	}

	qrCodeBase64 := base64.StdEncoding.EncodeToString(qrImageBytes)

	response := CodeResponse{
		Code:      qrCodeBase64,
		ExpiresAt: expiresAt.Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func (h *QRHandler) GenerateBarcode(w http.ResponseWriter, r *http.Request) {
	studentNumber, err := jwt.ExtractStudentNumberFromRequest(r, h.jwtSecret)
	if err != nil {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	barcodeImageBytes, expiresAt, err := h.qrService.GenerateBarcode(studentNumber)
	if err != nil {
		http.Error(w, "Failed to generate barcode", http.StatusInternalServerError)
		return
	}

	barcodeBase64 := base64.StdEncoding.EncodeToString(barcodeImageBytes)

	response := CodeResponse{
		Code:      barcodeBase64,
		ExpiresAt: expiresAt.Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
