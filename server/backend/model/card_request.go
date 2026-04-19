package model

import (
	"database/sql"
	"time"
)

type CardRequest struct {
	ID            int            `json:"id"`
	StudentNumber string         `json:"student_number"`
	RequestType   string         `json:"request_type"`
	RequestReason sql.NullString `json:"request_reason,omitempty"`
	RequestStatus string         `json:"request_status"`
	RequestedAt   time.Time      `json:"requested_at"`
	ProcessedAt   sql.NullTime   `json:"processed_at,omitempty"`
	ProcessedBy   sql.NullString `json:"processed_by,omitempty"`
	AdminNotes    sql.NullString `json:"admin_notes,omitempty"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
}
