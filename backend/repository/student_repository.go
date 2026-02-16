package repository

import (
	"context"
	"database/sql"
	"university-app/model"
)

type StudentRepository struct {
	db *sql.DB
}

func NewStudentRepository(db *sql.DB) *StudentRepository {
	return &StudentRepository{
		db: db,
	}
}

func (r *StudentRepository) GetAll(ctx context.Context) ([]model.Student, error) {
	query := `
		SELECT id, student_number, first_name, last_name, email, password_hash, program_code, card_issued_date, card_expiry_date, profile_photo_url, card_status, created_at, updated_at
		FROM students
		ORDER BY last_name, first_name
	`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var students []model.Student

	for rows.Next() {
		var student model.Student

		err := rows.Scan(
			&student.ID,
			&student.StudentNumber,
			&student.FirstName,
			&student.LastName,
			&student.Email,
			&student.PasswordHash,
			&student.ProgramCode,
			&student.CardIssuedDate,
			&student.CardExpiryDate,
			&student.ProfilePhotoURL,
			&student.CardStatus,
			&student.CreatedAt,
			&student.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		students = append(students, student)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return students, nil
}

func (r *StudentRepository) GetByStudentNumber(ctx context.Context, studentNumber string) (*model.Student, error) {
	query := `
		SELECT id, student_number, first_name, last_name, email, password_hash, program_code, card_issued_date, card_expiry_date, profile_photo_url, card_status, created_at, updated_at
		FROM students
		WHERE student_number = $1
	`

	row := r.db.QueryRowContext(ctx, query, studentNumber)

	var student model.Student
	err := row.Scan(
		&student.ID,
		&student.StudentNumber,
		&student.FirstName,
		&student.LastName,
		&student.Email,
		&student.PasswordHash,
		&student.ProgramCode,
		&student.CardIssuedDate,
		&student.CardExpiryDate,
		&student.ProfilePhotoURL,
		&student.CardStatus,
		&student.CreatedAt,
		&student.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}

	if err != nil {
		return nil, err
	}

	return &student, nil
}
