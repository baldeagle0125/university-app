package model

import (
	"encoding/json"
	"time"
)

type CreateFeedbackInput struct {
	FeedbackType string `json:"feedback_type"`
	Rating       *int   `json:"rating,omitempty"`
	Title        string `json:"title"`
	Message      string `json:"message"`
	AffectedArea string `json:"affected_area,omitempty"`
}

type FeedbackResponse struct {
	ID            int     `json:"id"`
	StudentNumber string  `json:"student_number"`
	FeedbackType  string  `json:"feedback_type"`
	Rating        *int    `json:"rating,omitempty"`
	Title         string  `json:"title"`
	Message       string  `json:"message"`
	AffectedArea  *string `json:"affected_area,omitempty"`
	CreatedAt     string  `json:"created_at"`
}

type CreateTelemetryEventInput struct {
	EventName      string         `json:"event_name"`
	EventCategory  string         `json:"event_category"`
	ContextPayload map[string]any `json:"context_payload,omitempty"`
	ScreenName     string         `json:"screen_name,omitempty"`
	AppVersion     string         `json:"app_version,omitempty"`
}

type TelemetryEventResponse struct {
	ID             int             `json:"id"`
	StudentNumber  string          `json:"student_number"`
	EventName      string          `json:"event_name"`
	EventCategory  string          `json:"event_category"`
	ContextPayload json.RawMessage `json:"context_payload,omitempty"`
	ScreenName     *string         `json:"screen_name,omitempty"`
	AppVersion     *string         `json:"app_version,omitempty"`
	CreatedAt      string          `json:"created_at"`
}

func (fe *FeedbackEntry) ToResponse() FeedbackResponse {
	return FeedbackResponse{
		ID:            fe.ID,
		StudentNumber: fe.StudentNumber,
		FeedbackType:  fe.FeedbackType,
		Rating:        nullInt32ToPtr(fe.Rating),
		Title:         fe.Title,
		Message:       fe.Message,
		AffectedArea:  nullStringToPtr(fe.AffectedArea),
		CreatedAt:     fe.CreatedAt.Format(time.RFC3339),
	}
}

func (te *TelemetryEvent) ToResponse() TelemetryEventResponse {
	return TelemetryEventResponse{
		ID:             te.ID,
		StudentNumber:  te.StudentNumber,
		EventName:      te.EventName,
		EventCategory:  te.EventCategory,
		ContextPayload: te.ContextPayload,
		ScreenName:     nullStringToPtr(te.ScreenName),
		AppVersion:     nullStringToPtr(te.AppVersion),
		CreatedAt:      te.CreatedAt.Format(time.RFC3339),
	}
}
