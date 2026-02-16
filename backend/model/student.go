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
	CardIssuedDate  sql.NullTime
	CardExpiryDate  sql.NullTime
	ProfilePhotoURL sql.NullString
	CardStatus      string
	CreatedAt       time.Time
	UpdatedAt       time.Time
}
