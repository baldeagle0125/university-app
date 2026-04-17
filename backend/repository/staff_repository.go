package repository

import (
	"context"
	"database/sql"
	"university-app/model"
)

type StaffRepository struct {
	db *sql.DB
}

func NewStaffRepository(db *sql.DB) *StaffRepository {
	return &StaffRepository{db: db}
}

func (r *StaffRepository) GetByStaffNumber(ctx context.Context, staffNumber string) (*model.Staff, error) {
	query := `
		SELECT id, staff_number, first_name, last_name, email, password_hash, role, is_active, created_at, updated_at
		FROM staff
		WHERE staff_number = $1
	`

	row := r.db.QueryRowContext(ctx, query, staffNumber)

	var staff model.Staff
	err := row.Scan(
		&staff.ID,
		&staff.StaffNumber,
		&staff.FirstName,
		&staff.LastName,
		&staff.Email,
		&staff.PasswordHash,
		&staff.Role,
		&staff.IsActive,
		&staff.CreatedAt,
		&staff.UpdatedAt,
	)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &staff, nil
}
