package repository

import (
	"context"
	"database/sql"
	"university-app/model"
)

type CardRequestRepository struct {
	db *sql.DB
}

func NewCardRequestRepository(db *sql.DB) *CardRequestRepository {
	return &CardRequestRepository{
		db: db,
	}
}

func (r *CardRequestRepository) CreateCardRequest(ctx context.Context, studentNumber, requestType, requestReason string) (*model.CardRequest, error) {
	query := `
		INSERT INTO card_requests (student_number, request_type, request_reason, status)
		VALUES ($1, $2, $3, 'pending')
		RETURNING id, student_number, request_type, request_reason, request_status, requested_at, processed_at, processed_by, admin_notes, created_at, updated_at
	`

	var cardRequest model.CardRequest
	err := r.db.QueryRowContext(ctx, query, studentNumber, requestType, requestReason).Scan(
		&cardRequest.ID,
		&cardRequest.StudentNumber,
		&cardRequest.RequestType,
		&cardRequest.RequestReason,
		&cardRequest.RequestStatus,
		&cardRequest.RequestedAt,
		&cardRequest.ProcessedAt,
		&cardRequest.ProcessedBy,
		&cardRequest.AdminNotes,
		&cardRequest.CreatedAt,
		&cardRequest.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return &cardRequest, nil
}

func (r *CardRequestRepository) GetCardRequestsByID(ctx context.Context, id int) (*model.CardRequest, error) {
	query := `
		SELECT id, student_number, request_type, request_reason, request_status, requested_at, processed_at, processed_by, admin_notes, created_at, updated_at
		FROM card_requests
		WHERE id = $1
	`

	var cardRequest model.CardRequest
	err := r.db.QueryRowContext(ctx, query, id).Scan(
		&cardRequest.ID,
		&cardRequest.StudentNumber,
		&cardRequest.RequestType,
		&cardRequest.RequestReason,
		&cardRequest.RequestStatus,
		&cardRequest.RequestedAt,
		&cardRequest.ProcessedAt,
		&cardRequest.ProcessedBy,
		&cardRequest.AdminNotes,
		&cardRequest.CreatedAt,
		&cardRequest.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &cardRequest, nil
}

func (r *CardRequestRepository) GetCardRequestsByStudentNumber(ctx context.Context, studentNumber string) ([]model.CardRequest, error) {
	query := `
		SELECT id, student_number, request_type, request_reason, request_status, requested_at, processed_at, processed_by, admin_notes, created_at, updated_at
		FROM card_requests
		WHERE student_number = $1
		ORDER BY requested_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, studentNumber)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cardRequests []model.CardRequest
	for rows.Next() {
		var cardRequest model.CardRequest
		err := rows.Scan(
			&cardRequest.ID,
			&cardRequest.StudentNumber,
			&cardRequest.RequestType,
			&cardRequest.RequestReason,
			&cardRequest.RequestStatus,
			&cardRequest.RequestedAt,
			&cardRequest.ProcessedAt,
			&cardRequest.ProcessedBy,
			&cardRequest.AdminNotes,
			&cardRequest.CreatedAt,
			&cardRequest.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		cardRequests = append(cardRequests, cardRequest)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return cardRequests, nil
}

func (r *CardRequestRepository) GetPendingCardRequests(ctx context.Context) ([]model.CardRequest, error) {
	query := `
		SELECT id, student_number, request_type, request_reason, request_status, requested_at, processed_at, processed_by, admin_notes, created_at, updated_at
		FROM card_requests
		WHERE request_status = 'pending'
		ORDER BY requested_at ASC
	`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cardRequests []model.CardRequest
	for rows.Next() {
		var cardRequest model.CardRequest
		err := rows.Scan(
			&cardRequest.ID,
			&cardRequest.StudentNumber,
			&cardRequest.RequestType,
			&cardRequest.RequestReason,
			&cardRequest.RequestStatus,
			&cardRequest.RequestedAt,
			&cardRequest.ProcessedAt,
			&cardRequest.ProcessedBy,
			&cardRequest.AdminNotes,
			&cardRequest.CreatedAt,
			&cardRequest.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		cardRequests = append(cardRequests, cardRequest)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return cardRequests, nil
}

func (r *CardRequestRepository) ProcessCardRequest(ctx context.Context, id int, status, processedBy, adminNotes string) (*model.CardRequest, error) {
	query := `
		UPDATE card_requests
		SET request_status = $1, processed_by = $2, admin_notes = $3, processed_at = NOW(), updated_at = NOW()
		WHERE id = $4
		RETURNING id, student_number, request_type, request_reason, request_status, requested_at, processed_at, processed_by, admin_notes, created_at, updated_at
	`

	var cardRequest model.CardRequest
	err := r.db.QueryRowContext(ctx, query, status, processedBy, adminNotes, id).Scan(
		&cardRequest.ID,
		&cardRequest.StudentNumber,
		&cardRequest.RequestType,
		&cardRequest.RequestReason,
		&cardRequest.RequestStatus,
		&cardRequest.RequestedAt,
		&cardRequest.ProcessedAt,
		&cardRequest.ProcessedBy,
		&cardRequest.AdminNotes,
		&cardRequest.CreatedAt,
		&cardRequest.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &cardRequest, nil
}

func (r *CardRequestRepository) UpdateStudentCardStatus(ctx context.Context, studentNumber, cardStatus string) error {
	query := `
		UPDATE students
		SET card_status = $1, updated_at = NOW()
		WHERE student_number = $2
	`

	_, err := r.db.ExecContext(ctx, query, cardStatus, studentNumber)
	return err
}

func (r *CardRequestRepository) GetLatestCardRequestByStudentNumber(ctx context.Context, studentNumber string) (*model.CardRequest, error) {
	query := `
		SELECT id, student_number, request_type, request_reason, request_status, requested_at, processed_at, processed_by, admin_notes, created_at, updated_at
		FROM card_requests
		WHERE student_number = $1
		ORDER BY requested_at DESC
		LIMIT 1
	`

	var cardRequest model.CardRequest
	err := r.db.QueryRowContext(ctx, query, studentNumber).Scan(
		&cardRequest.ID,
		&cardRequest.StudentNumber,
		&cardRequest.RequestType,
		&cardRequest.RequestReason,
		&cardRequest.RequestStatus,
		&cardRequest.RequestedAt,
		&cardRequest.ProcessedAt,
		&cardRequest.ProcessedBy,
		&cardRequest.AdminNotes,
		&cardRequest.CreatedAt,
		&cardRequest.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &cardRequest, nil
}
