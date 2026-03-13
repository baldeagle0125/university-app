package model

import (
	"database/sql"
	"time"
)

type Student struct {
	ID              int
	StudentNumber   string
	FirstName       string
	LastName        string
	Email           string
	PasswordHash    string
	ProgramCode     sql.NullString
	CourseTitle     sql.NullString
	DateOfBirth     sql.NullTime
	SUPosition      sql.NullString
	Memberships     []string
	CardIssuedDate  sql.NullTime
	CardExpiryDate  sql.NullTime
	ProfilePhotoURL sql.NullString
	CardStatus      string
	CreatedAt       time.Time
	UpdatedAt       time.Time
}
