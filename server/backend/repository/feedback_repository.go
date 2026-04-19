package repository

import (
	"context"
	"database/sql"
	"encoding/json"
	"university-app/model"
)

type FeedbackRepository struct {
	db *sql.DB
}

func NewFeedbackRepository(db *sql.DB) *FeedbackRepository {
	return &FeedbackRepository{db: db}
}

func (r *FeedbackRepository) CreateFeedbackEntry(ctx context.Context, studentNumber string, input model.CreateFeedbackInput) (*model.FeedbackEntry, error) {
	query := `
		INSERT INTO feedback_entries (student_number, feedback_type, rating, title, message, affected_area)
		VALUES ($1, $2, $3, $4, $5, NULLIF($6, ''))
		RETURNING id, student_number, feedback_type, rating, title, message, affected_area, created_at, updated_at
	`

	var feedback model.FeedbackEntry
	err := r.db.QueryRowContext(ctx, query, studentNumber, input.FeedbackType, input.Rating, input.Title, input.Message, input.AffectedArea).Scan(
		&feedback.ID,
		&feedback.StudentNumber,
		&feedback.FeedbackType,
		&feedback.Rating,
		&feedback.Title,
		&feedback.Message,
		&feedback.AffectedArea,
		&feedback.CreatedAt,
		&feedback.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &feedback, nil
}

func (r *FeedbackRepository) CreateTelemetryEvent(ctx context.Context, studentNumber string, input model.CreateTelemetryEventInput) (*model.TelemetryEvent, error) {
	query := `
		INSERT INTO telemetry_events (student_number, event_name, event_category, context_payload, screen_name, app_version)
		VALUES ($1, $2, $3, $4, NULLIF($5, ''), NULLIF($6, ''))
		RETURNING id, student_number, event_name, event_category, context_payload, screen_name, app_version, created_at, updated_at
	`

	var payload []byte
	if len(input.ContextPayload) > 0 {
		encodedPayload, err := json.Marshal(input.ContextPayload)
		if err != nil {
			return nil, err
		}
		payload = encodedPayload
	}

	var event model.TelemetryEvent
	err := r.db.QueryRowContext(ctx, query, studentNumber, input.EventName, input.EventCategory, payload, input.ScreenName, input.AppVersion).Scan(
		&event.ID,
		&event.StudentNumber,
		&event.EventName,
		&event.EventCategory,
		&event.ContextPayload,
		&event.ScreenName,
		&event.AppVersion,
		&event.CreatedAt,
		&event.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	if event.ContextPayload == nil {
		event.ContextPayload = json.RawMessage([]byte("{}"))
	}

	return &event, nil
}

func (r *FeedbackRepository) ListFeedbackEntries(ctx context.Context, feedbackType, studentNumber string, limit, offset int) ([]model.FeedbackEntry, error) {
	query := `
		SELECT id, student_number, feedback_type, rating, title, message, affected_area, created_at, updated_at
		FROM feedback_entries
		WHERE ($1 = '' OR feedback_type = $1)
			AND ($2 = '' OR student_number = $2)
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4
	`

	rows, err := r.db.QueryContext(ctx, query, feedbackType, studentNumber, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	entries := make([]model.FeedbackEntry, 0)
	for rows.Next() {
		var entry model.FeedbackEntry
		err = rows.Scan(
			&entry.ID,
			&entry.StudentNumber,
			&entry.FeedbackType,
			&entry.Rating,
			&entry.Title,
			&entry.Message,
			&entry.AffectedArea,
			&entry.CreatedAt,
			&entry.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		entries = append(entries, entry)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return entries, nil
}

func (r *FeedbackRepository) ListTelemetryEvents(ctx context.Context, eventName, eventCategory, studentNumber string, limit, offset int) ([]model.TelemetryEvent, error) {
	query := `
		SELECT id, student_number, event_name, event_category, context_payload, screen_name, app_version, created_at, updated_at
		FROM telemetry_events
		WHERE ($1 = '' OR event_name = $1)
			AND ($2 = '' OR event_category = $2)
			AND ($3 = '' OR student_number = $3)
		ORDER BY created_at DESC
		LIMIT $4 OFFSET $5
	`

	rows, err := r.db.QueryContext(ctx, query, eventName, eventCategory, studentNumber, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	events := make([]model.TelemetryEvent, 0)
	for rows.Next() {
		var event model.TelemetryEvent
		err = rows.Scan(
			&event.ID,
			&event.StudentNumber,
			&event.EventName,
			&event.EventCategory,
			&event.ContextPayload,
			&event.ScreenName,
			&event.AppVersion,
			&event.CreatedAt,
			&event.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		if event.ContextPayload == nil {
			event.ContextPayload = json.RawMessage([]byte("{}"))
		}

		events = append(events, event)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return events, nil
}
