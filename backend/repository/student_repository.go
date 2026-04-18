package repository

import (
	"context"
	"database/sql"
	"strings"
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

func (r *StudentRepository) GetAll(ctx context.Context, search, cardStatus, programCode string, limit, offset int) ([]model.Student, error) {
	query := `
		SELECT id, student_number, first_name, last_name, email, password_hash, program_code, course_title, date_of_birth, su_position, card_issued_date, card_expiry_date, profile_photo_url, card_status, created_at, updated_at
		FROM students
		WHERE (
			$1 = ''
			OR student_number ILIKE '%' || $1 || '%'
			OR email ILIKE '%' || $1 || '%'
			OR first_name ILIKE '%' || $1 || '%'
			OR last_name ILIKE '%' || $1 || '%'
		)
			AND ($2 = '' OR card_status = $2)
			AND ($3 = '' OR program_code = $3)
		ORDER BY last_name, first_name
		LIMIT $4 OFFSET $5
	`

	rows, err := r.db.QueryContext(ctx, query, search, cardStatus, programCode, limit, offset)
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
			&student.CourseTitle,
			&student.DateOfBirth,
			&student.SUPosition,
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

	for i := range students {
		memberships, err := r.getMembershipsByStudentNumber(ctx, students[i].StudentNumber)
		if err != nil {
			return nil, err
		}

		students[i].Memberships = memberships
	}

	return students, nil
}

func (r *StudentRepository) Create(ctx context.Context, student model.Student) (*model.Student, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}

	defer func() {
		if err != nil {
			_ = tx.Rollback()
		}
	}()

	query := `
		INSERT INTO students (
			student_number,
			first_name,
			last_name,
			email,
			password_hash,
			program_code,
			course_title,
			date_of_birth,
			su_position,
			card_issued_date,
			card_expiry_date,
			profile_photo_url,
			card_status
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
		RETURNING id, student_number, first_name, last_name, email, password_hash, program_code, course_title, date_of_birth, su_position, card_issued_date, card_expiry_date, profile_photo_url, card_status, created_at, updated_at
	`

	err = tx.QueryRowContext(
		ctx,
		query,
		student.StudentNumber,
		student.FirstName,
		student.LastName,
		student.Email,
		student.PasswordHash,
		student.ProgramCode,
		student.CourseTitle,
		student.DateOfBirth,
		student.SUPosition,
		student.CardIssuedDate,
		student.CardExpiryDate,
		student.ProfilePhotoURL,
		student.CardStatus,
	).Scan(
		&student.ID,
		&student.StudentNumber,
		&student.FirstName,
		&student.LastName,
		&student.Email,
		&student.PasswordHash,
		&student.ProgramCode,
		&student.CourseTitle,
		&student.DateOfBirth,
		&student.SUPosition,
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

	student.Memberships, err = r.replaceMembershipsTx(ctx, tx, student.StudentNumber, student.Memberships)
	if err != nil {
		return nil, err
	}

	err = tx.Commit()
	if err != nil {
		return nil, err
	}

	return &student, nil
}

func (r *StudentRepository) GetByID(ctx context.Context, id int) (*model.Student, error) {
	query := `
		SELECT id, student_number, first_name, last_name, email, password_hash, program_code, course_title, date_of_birth, su_position, card_issued_date, card_expiry_date, profile_photo_url, card_status, created_at, updated_at
		FROM students
		WHERE id = $1
	`

	row := r.db.QueryRowContext(ctx, query, id)

	var student model.Student
	err := row.Scan(
		&student.ID,
		&student.StudentNumber,
		&student.FirstName,
		&student.LastName,
		&student.Email,
		&student.PasswordHash,
		&student.ProgramCode,
		&student.CourseTitle,
		&student.DateOfBirth,
		&student.SUPosition,
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

	memberships, err := r.getMembershipsByStudentNumber(ctx, student.StudentNumber)
	if err != nil {
		return nil, err
	}

	student.Memberships = memberships

	return &student, nil
}

func (r *StudentRepository) UpdateByID(ctx context.Context, id int, student model.Student) (*model.Student, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}

	defer func() {
		if err != nil {
			_ = tx.Rollback()
		}
	}()

	query := `
		UPDATE students
		SET
			student_number = $1,
			first_name = $2,
			last_name = $3,
			email = $4,
			password_hash = $5,
			program_code = $6,
			course_title = $7,
			date_of_birth = $8,
			su_position = $9,
			card_issued_date = $10,
			card_expiry_date = $11,
			profile_photo_url = $12,
			card_status = $13,
			updated_at = NOW()
		WHERE id = $14
		RETURNING id, student_number, first_name, last_name, email, password_hash, program_code, course_title, date_of_birth, su_position, card_issued_date, card_expiry_date, profile_photo_url, card_status, created_at, updated_at
	`

	err = tx.QueryRowContext(
		ctx,
		query,
		student.StudentNumber,
		student.FirstName,
		student.LastName,
		student.Email,
		student.PasswordHash,
		student.ProgramCode,
		student.CourseTitle,
		student.DateOfBirth,
		student.SUPosition,
		student.CardIssuedDate,
		student.CardExpiryDate,
		student.ProfilePhotoURL,
		student.CardStatus,
		id,
	).Scan(
		&student.ID,
		&student.StudentNumber,
		&student.FirstName,
		&student.LastName,
		&student.Email,
		&student.PasswordHash,
		&student.ProgramCode,
		&student.CourseTitle,
		&student.DateOfBirth,
		&student.SUPosition,
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

	student.Memberships, err = r.replaceMembershipsTx(ctx, tx, student.StudentNumber, student.Memberships)
	if err != nil {
		return nil, err
	}

	err = tx.Commit()
	if err != nil {
		return nil, err
	}

	return &student, nil
}

func (r *StudentRepository) DeleteByID(ctx context.Context, id int) (bool, error) {
	result, err := r.db.ExecContext(ctx, `DELETE FROM students WHERE id = $1`, id)
	if err != nil {
		return false, err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return false, err
	}

	return rowsAffected > 0, nil
}

func (r *StudentRepository) GetByStudentNumber(ctx context.Context, studentNumber string) (*model.Student, error) {
	query := `
		SELECT id, student_number, first_name, last_name, email, password_hash, program_code, course_title, date_of_birth, su_position, card_issued_date, card_expiry_date, profile_photo_url, card_status, created_at, updated_at
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
		&student.CourseTitle,
		&student.DateOfBirth,
		&student.SUPosition,
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

	memberships, err := r.getMembershipsByStudentNumber(ctx, studentNumber)
	if err != nil {
		return nil, err
	}

	student.Memberships = memberships

	return &student, nil
}

func (r *StudentRepository) getMembershipsByStudentNumber(ctx context.Context, studentNumber string) ([]string, error) {
	query := `
		SELECT membership_name
		FROM student_memberships
		WHERE student_number = $1
		ORDER BY membership_name
	`

	rows, err := r.db.QueryContext(ctx, query, studentNumber)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	memberships := []string{}
	for rows.Next() {
		var membership string
		if err := rows.Scan(&membership); err != nil {
			return nil, err
		}

		memberships = append(memberships, membership)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return memberships, nil
}

func (r *StudentRepository) replaceMembershipsTx(ctx context.Context, tx *sql.Tx, studentNumber string, memberships []string) ([]string, error) {
	if _, err := tx.ExecContext(ctx, `DELETE FROM student_memberships WHERE student_number = $1`, studentNumber); err != nil {
		return nil, err
	}

	cleanMemberships := dedupeMemberships(memberships)
	if len(cleanMemberships) == 0 {
		return []string{}, nil
	}

	query := `
		INSERT INTO student_memberships (student_number, membership_name)
		VALUES ($1, $2)
	`

	for _, membership := range cleanMemberships {
		if _, err := tx.ExecContext(ctx, query, studentNumber, membership); err != nil {
			return nil, err
		}
	}

	return cleanMemberships, nil
}

func dedupeMemberships(memberships []string) []string {
	seen := make(map[string]struct{})
	cleanMemberships := make([]string, 0, len(memberships))

	for _, membership := range memberships {
		cleanMembership := strings.TrimSpace(membership)
		if cleanMembership == "" {
			continue
		}

		if _, ok := seen[cleanMembership]; ok {
			continue
		}

		seen[cleanMembership] = struct{}{}
		cleanMemberships = append(cleanMemberships, cleanMembership)
	}

	return cleanMemberships
}
