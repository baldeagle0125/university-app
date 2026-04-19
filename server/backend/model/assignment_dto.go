package model

import "time"

type AssignmentResponse struct {
	ID             int     `json:"id"`
	StudentNumber  string  `json:"student_number"`
	Title          string  `json:"title"`
	Description    *string `json:"description,omitempty"`
	DueDate        string  `json:"due_date"`
	Status         string  `json:"status"`
	DaysUntilDue   int     `json:"days_until_due"`
	IsOverdue      bool    `json:"is_overdue"`
	SubmissionText *string `json:"submission_text,omitempty"`
	SubmittedAt    *string `json:"submitted_at,omitempty"`
	CreatedAt      string  `json:"created_at"`
	UpdatedAt      string  `json:"updated_at"`
}

type SubmitAssignmentInput struct {
	SubmissionText string `json:"submission_text"`
}

func (a *Assignment) ToResponse(now time.Time) AssignmentResponse {
	dueDateStart := time.Date(a.DueDate.Year(), a.DueDate.Month(), a.DueDate.Day(), 0, 0, 0, 0, time.UTC)
	nowStart := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
	daysUntilDue := int(dueDateStart.Sub(nowStart).Hours() / 24)
	isOverdue := !a.IsSubmitted() && dueDateStart.Before(nowStart)

	status := a.Status
	if isOverdue {
		status = "overdue"
	}

	return AssignmentResponse{
		ID:             a.ID,
		StudentNumber:  a.StudentNumber,
		Title:          a.Title,
		Description:    nullStringToPtr(a.Description),
		DueDate:        a.DueDate.Format(time.RFC3339),
		Status:         status,
		DaysUntilDue:   daysUntilDue,
		IsOverdue:      isOverdue,
		SubmissionText: nullStringToPtr(a.SubmissionText),
		SubmittedAt:    nullTimeToPtr(a.SubmittedAt),
		CreatedAt:      a.CreatedAt.Format(time.RFC3339),
		UpdatedAt:      a.UpdatedAt.Format(time.RFC3339),
	}
}
