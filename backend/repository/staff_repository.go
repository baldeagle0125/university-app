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

func (r *StaffRepository) GetByID(ctx context.Context, id int) (*model.Staff, error) {
	query := `
		SELECT id, staff_number, first_name, last_name, email, password_hash, role, is_active, created_at, updated_at
		FROM staff
		WHERE id = $1
	`

	row := r.db.QueryRowContext(ctx, query, id)

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

func (r *StaffRepository) List(ctx context.Context, role string, isActive *bool, limit, offset int) ([]model.Staff, error) {
	query := `
		SELECT id, staff_number, first_name, last_name, email, password_hash, role, is_active, created_at, updated_at
		FROM staff
		WHERE ($1 = '' OR role = $1)
			AND ($2::boolean IS NULL OR is_active = $2)
		ORDER BY created_at DESC
		LIMIT $3 OFFSET $4
	`

	rows, err := r.db.QueryContext(ctx, query, role, isActive, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	staffList := make([]model.Staff, 0)
	for rows.Next() {
		var staff model.Staff
		err = rows.Scan(
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
		if err != nil {
			return nil, err
		}

		staffList = append(staffList, staff)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return staffList, nil
}

func (r *StaffRepository) Create(ctx context.Context, staff model.Staff) (*model.Staff, error) {
	query := `
		INSERT INTO staff (staff_number, first_name, last_name, email, password_hash, role, is_active)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, staff_number, first_name, last_name, email, password_hash, role, is_active, created_at, updated_at
	`

	err := r.db.QueryRowContext(
		ctx,
		query,
		staff.StaffNumber,
		staff.FirstName,
		staff.LastName,
		staff.Email,
		staff.PasswordHash,
		staff.Role,
		staff.IsActive,
	).Scan(
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
	if err != nil {
		return nil, err
	}

	return &staff, nil
}

func (r *StaffRepository) UpdateByID(ctx context.Context, id int, staff model.Staff) (*model.Staff, error) {
	query := `
		UPDATE staff
		SET first_name = $1,
			last_name = $2,
			email = $3,
			password_hash = $4,
			role = $5,
			is_active = $6,
			updated_at = NOW()
		WHERE id = $7
		RETURNING id, staff_number, first_name, last_name, email, password_hash, role, is_active, created_at, updated_at
	`

	err := r.db.QueryRowContext(
		ctx,
		query,
		staff.FirstName,
		staff.LastName,
		staff.Email,
		staff.PasswordHash,
		staff.Role,
		staff.IsActive,
		id,
	).Scan(
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
