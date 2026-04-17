package model

import (
	"database/sql"
	"encoding/json"
	"time"
)

type FeedbackEntry struct {
	ID            int            `json:"id"`
	StudentNumber string         `json:"student_number"`
	FeedbackType  string         `json:"feedback_type"`
	Rating        sql.NullInt32  `json:"rating,omitempty"`
	Title         string         `json:"title"`
	Message       string         `json:"message"`
	AffectedArea  sql.NullString `json:"affected_area,omitempty"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
}

type TelemetryEvent struct {
	ID             int             `json:"id"`
	StudentNumber  string          `json:"student_number"`
	EventName      string          `json:"event_name"`
	EventCategory  string          `json:"event_category"`
	ContextPayload json.RawMessage `json:"context_payload,omitempty"`
	ScreenName     sql.NullString  `json:"screen_name,omitempty"`
	AppVersion     sql.NullString  `json:"app_version,omitempty"`
	CreatedAt      time.Time       `json:"created_at"`
	UpdatedAt      time.Time       `json:"updated_at"`
}
