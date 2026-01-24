package repository

import (
	"context"
	"database/sql"
	"university-app/models"
)

type StudentRepository struct {
	db *sql.DB
}

func NewStudentRepository(db *sql.DB) *StudentRepository {
	return &StudentRepository{
		db: db,
	}
}

func (r *StudentRepository) GetAll(ctx context.Context) ([]models.Student, error) {
	query := `
		SELECT id, student_number, first_name, last_name, email, password_hash
		FROM students
		ORDER BY last_name, first_name
	`

	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var students []models.Student

	for rows.Next() {
		var student models.Student

		err := rows.Scan(
			&student.ID,
			&student.StudentNumber,
			&student.FirstName,
			&student.LastName,
			&student.Email,
			&student.PasswordHash,
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
