package repository

import (
	"context"
	"database/sql"
	"university-app/model"
)

type AssignmentRepository struct {
	db *sql.DB
}

func NewAssignmentRepository(db *sql.DB) *AssignmentRepository {
	return &AssignmentRepository{db: db}
}

func (r *AssignmentRepository) GetAssignmentsByStudentNumber(ctx context.Context, studentNumber string) ([]model.Assignment, error) {
	query := `
		SELECT id, student_number, title, description, due_date, status, submission_text, submitted_at, created_at, updated_at
		FROM assignments
		WHERE student_number = $1
		ORDER BY due_date ASC, created_at DESC
	`

	rows, err := r.db.QueryContext(ctx, query, studentNumber)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	assignments := make([]model.Assignment, 0)
	for rows.Next() {
		var assignment model.Assignment
		err := rows.Scan(
			&assignment.ID,
			&assignment.StudentNumber,
			&assignment.Title,
			&assignment.Description,
			&assignment.DueDate,
			&assignment.Status,
			&assignment.SubmissionText,
			&assignment.SubmittedAt,
			&assignment.CreatedAt,
			&assignment.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		assignments = append(assignments, assignment)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return assignments, nil
}

func (r *AssignmentRepository) GetAssignmentByIDAndStudentNumber(ctx context.Context, id int, studentNumber string) (*model.Assignment, error) {
	query := `
		SELECT id, student_number, title, description, due_date, status, submission_text, submitted_at, created_at, updated_at
		FROM assignments
		WHERE id = $1 AND student_number = $2
	`

	var assignment model.Assignment
	err := r.db.QueryRowContext(ctx, query, id, studentNumber).Scan(
		&assignment.ID,
		&assignment.StudentNumber,
		&assignment.Title,
		&assignment.Description,
		&assignment.DueDate,
		&assignment.Status,
		&assignment.SubmissionText,
		&assignment.SubmittedAt,
		&assignment.CreatedAt,
		&assignment.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &assignment, nil
}

func (r *AssignmentRepository) SubmitAssignment(ctx context.Context, id int, studentNumber, submissionText string) (*model.Assignment, error) {
	query := `
		UPDATE assignments
		SET submission_text = $1, status = 'submitted', submitted_at = NOW(), updated_at = NOW()
		WHERE id = $2 AND student_number = $3
		RETURNING id, student_number, title, description, due_date, status, submission_text, submitted_at, created_at, updated_at
	`

	var assignment model.Assignment
	err := r.db.QueryRowContext(ctx, query, submissionText, id, studentNumber).Scan(
		&assignment.ID,
		&assignment.StudentNumber,
		&assignment.Title,
		&assignment.Description,
		&assignment.DueDate,
		&assignment.Status,
		&assignment.SubmissionText,
		&assignment.SubmittedAt,
		&assignment.CreatedAt,
		&assignment.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &assignment, nil
}

func (r *AssignmentRepository) SeedDefaultAssignmentsForStudent(ctx context.Context, studentNumber string) error {
	query := `
		INSERT INTO assignments (student_number, title, description, due_date, status)
		SELECT $1, assignment.title, assignment.description, assignment.due_date, 'assigned'
		FROM (
			VALUES
				('Database Design Report', 'Submit normalization analysis for the student portal system.', NOW() + INTERVAL '2 days'),
				('Operating Systems Lab', 'Upload lab notes and process scheduling screenshots.', NOW() + INTERVAL '5 days'),
				('Linear Algebra Problem Set', 'Complete tasks 1-10 from chapter 4.', NOW() - INTERVAL '1 day')
		) AS assignment(title, description, due_date)
		WHERE NOT EXISTS (
			SELECT 1 FROM assignments WHERE student_number = $1
		)
	`

	_, err := r.db.ExecContext(ctx, query, studentNumber)

	return err
}

func (r *AssignmentRepository) ListAssignmentsForAdmin(ctx context.Context, status, studentNumber, titleContains string, limit, offset int) ([]model.Assignment, error) {
	query := `
		SELECT id, student_number, title, description, due_date, status, submission_text, submitted_at, created_at, updated_at
		FROM assignments
		WHERE (
			$1 = ''
			OR ($1 = 'overdue' AND status = 'assigned' AND due_date < NOW())
			OR ($1 IN ('assigned', 'submitted') AND status = $1)
		)
			AND ($2 = '' OR student_number = $2)
			AND ($3 = '' OR title ILIKE '%' || $3 || '%')
		ORDER BY due_date ASC, created_at DESC
		LIMIT $4 OFFSET $5
	`

	rows, err := r.db.QueryContext(ctx, query, status, studentNumber, titleContains, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	assignments := make([]model.Assignment, 0)
	for rows.Next() {
		var assignment model.Assignment
		err = rows.Scan(
			&assignment.ID,
			&assignment.StudentNumber,
			&assignment.Title,
			&assignment.Description,
			&assignment.DueDate,
			&assignment.Status,
			&assignment.SubmissionText,
			&assignment.SubmittedAt,
			&assignment.CreatedAt,
			&assignment.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		assignments = append(assignments, assignment)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return assignments, nil
}
