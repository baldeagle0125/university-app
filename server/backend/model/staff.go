package model

import "time"

type Staff struct {
	ID           int
	StaffNumber  string
	FirstName    string
	LastName     string
	Email        string
	PasswordHash string
	Role         string
	IsActive     bool
	CreatedAt    time.Time
	UpdatedAt    time.Time
}
