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

type VerifyRequest struct {
	Token string `json:"token"`
}

type VerifyResponse struct {
	IsValid       bool   `json:"is_valid"`
	StudentNumber string `json:"student_number"`
	Message       string `json:"message,omitempty"`
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

func (h *QRHandler) VerifyCode(w http.ResponseWriter, r *http.Request) {
	var veryfyRequest VerifyRequest
	err := json.NewDecoder(r.Body).Decode(&veryfyRequest)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	if veryfyRequest.Token == "" {
		reponse := VerifyResponse{
			IsValid: false,
			Message: "Token is required",
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(reponse)
		return
	}

	studentNumber, err := h.qrService.VerifyToken(veryfyRequest.Token)
	if err != nil {
		response := VerifyResponse{
			IsValid: false,
			Message: err.Error(),
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
		return
	}

	response := VerifyResponse{
		IsValid:       true,
		StudentNumber: studentNumber,
		Message:       "Valid student ID",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
