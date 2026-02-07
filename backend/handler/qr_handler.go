package handler

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"time"
	"university-app/service"
)

type QRHandler struct {
	qrService *service.QRService
}

func NewQRHandler(qrService *service.QRService) *QRHandler {
	return &QRHandler{
		qrService: qrService,
	}
}

type QRCodeResponse struct {
	QRCode    string `json:"qr_code"`
	Token     string `json:"token"`
	ExpiresAt string `json:"expires_at"`
}

func (h *QRHandler) GenerateQRCode(w http.ResponseWriter, r *http.Request) {
	studentNumber := "SETU000001"

	qrImageBytes, expiresAt, err := h.qrService.GenerateQRCode(studentNumber)
	if err != nil {
		http.Error(w, "Failed to generate QR code", http.StatusInternalServerError)
		return
	}

	qrCodeBase64 := base64.StdEncoding.EncodeToString(qrImageBytes)

	response := QRCodeResponse{
		QRCode:    qrCodeBase64,
		Token:     "",
		ExpiresAt: expiresAt.Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
