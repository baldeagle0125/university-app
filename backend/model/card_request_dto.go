package model

import (
	"database/sql"
	"time"
)

type CardRequestResponse struct {
	ID            int     `json:"id"`
	StudentNumber string  `json:"student_number"`
	RequestType   string  `json:"request_type"`
	RequestReason *string `json:"request_reason,omitempty"`
	RequestStatus string  `json:"request_status"`
	RequestedAt   string  `json:"requested_at"`
	ProcessedAt   *string `json:"processed_at,omitempty"`
	ProcessedBy   string  `json:"processed_by"`
	AdminNotes    *string `json:"admin_notes,omitempty"`
	CreatedAt     string  `json:"created_at"`
	UpdatedAt     string  `json:"updated_at"`
}

func (cr *CardRequest) ToResponse() CardRequestResponse {
	return CardRequestResponse{
		ID:            cr.ID,
		StudentNumber: cr.StudentNumber,
		RequestType:   cr.RequestType,
		RequestReason: nullStringToPtr(cr.RequestReason),
		RequestStatus: cr.RequestStatus,
		RequestedAt:   cr.RequestedAt.Format(time.RFC3339),
		ProcessedAt:   nullTimeToPtr(cr.ProcessedAt),
		ProcessedBy:   *nullStringToPtr(cr.ProcessedBy),
		AdminNotes:    nullStringToPtr(sql.NullString{String: cr.AdminNotes, Valid: cr.AdminNotes != ""}),
		CreatedAt:     cr.CreatedAt.Format(time.RFC3339),
		UpdatedAt:     cr.UpdatedAt.Format(time.RFC3339),
	}
}

type CreateCardRequestInput struct {
	RequestType   string `json:"request_type"`
	RequestReason string `json:"request_reason"`
}

type ProcessCardRequest struct {
	RequestStatus string `json:"request_status"`
	AdminNotes    string `json:"admin_notes"`
}
