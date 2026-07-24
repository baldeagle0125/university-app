package service

import (
	"bytes"
	"testing"
	"time"
)

func TestQRTokenRoundTrip(t *testing.T) {
	service := NewQRService([]byte("test-secret"))

	token, expiresAt, err := service.GenerateToken("S202401")
	if err != nil {
		t.Fatalf("GenerateToken returned an error: %v", err)
	}
	if !expiresAt.After(time.Now()) {
		t.Fatal("GenerateToken returned an expiry in the past")
	}

	studentNumber, err := service.VerifyToken(token)
	if err != nil {
		t.Fatalf("VerifyToken returned an error: %v", err)
	}
	if studentNumber != "S202401" {
		t.Fatalf("VerifyToken returned %q, want %q", studentNumber, "S202401")
	}
}

func TestBarcodeTokenRoundTrip(t *testing.T) {
	service := NewQRService([]byte("test-secret"))

	token, _, err := service.GenerateBarcodeToken("S202401")
	if err != nil {
		t.Fatalf("GenerateBarcodeToken returned an error: %v", err)
	}

	studentNumber, err := service.VerifyToken(token)
	if err != nil {
		t.Fatalf("VerifyToken returned an error: %v", err)
	}
	if studentNumber != "S202401" {
		t.Fatalf("VerifyToken returned %q, want %q", studentNumber, "S202401")
	}
}

func TestVerifyTokenRejectsTampering(t *testing.T) {
	service := NewQRService([]byte("test-secret"))

	token, _, err := service.GenerateToken("S202401")
	if err != nil {
		t.Fatalf("GenerateToken returned an error: %v", err)
	}

	tampered := []byte(token)
	tampered[len(tampered)-1] ^= 1

	if _, err := service.VerifyToken(string(tampered)); err == nil {
		t.Fatal("VerifyToken accepted a tampered token")
	}
}

func TestGeneratedImagesArePNG(t *testing.T) {
	service := NewQRService([]byte("test-secret"))
	pngSignature := []byte{0x89, 'P', 'N', 'G', '\r', '\n', 0x1a, '\n'}

	qrCode, _, err := service.GenerateQRCode("S202401")
	if err != nil {
		t.Fatalf("GenerateQRCode returned an error: %v", err)
	}
	if !bytes.HasPrefix(qrCode, pngSignature) {
		t.Fatal("GenerateQRCode did not return a PNG image")
	}

	barcodeImage, _, err := service.GenerateBarcode("S202401")
	if err != nil {
		t.Fatalf("GenerateBarcode returned an error: %v", err)
	}
	if !bytes.HasPrefix(barcodeImage, pngSignature) {
		t.Fatal("GenerateBarcode did not return a PNG image")
	}
}
