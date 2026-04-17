package model

import (
	"database/sql"
	"time"
)

type Assignment struct {
	ID             int
	StudentNumber  string
	Title          string
	Description    sql.NullString
	DueDate        time.Time
	Status         string
	SubmissionText sql.NullString
	SubmittedAt    sql.NullTime
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

func (a *Assignment) IsSubmitted() bool {
	return a.Status == "submitted"
}
