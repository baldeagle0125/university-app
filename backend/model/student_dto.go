package model

import "time"

type StudentResponse struct {
	ID              int     `json:"id"`
	StudentNumber   string  `json:"student_number"`
	FirstName       string  `json:"first_name"`
	LastName        string  `json:"last_name"`
	Email           string  `json:"email"`
	ProgramCode     *string `json:"program_code,omitempty"`
	CardIssuedDate  *string `json:"card_issued_date,omitempty"`
	CardExpiryDate  *string `json:"card_expiry_date,omitempty"`
	ProfilePhotoURL *string `json:"profile_photo_url,omitempty"`
	CardStatus      string  `json:"card_status"`
	CreatedAt       string  `json:"created_at"`
	UpdatedAt       string  `json:"updated_at"`
}

func (s *Student) ToResponse() StudentResponse {
	return StudentResponse{
		ID:              s.ID,
		StudentNumber:   s.StudentNumber,
		FirstName:       s.FirstName,
		LastName:        s.LastName,
		Email:           s.Email,
		ProgramCode:     nullStringToPtr(s.ProgramCode),
		CardIssuedDate:  nullTimeToPtr(s.CardIssuedDate),
		CardExpiryDate:  nullTimeToPtr(s.CardExpiryDate),
		ProfilePhotoURL: nullStringToPtr(s.ProfilePhotoURL),
		CardStatus:      s.CardStatus,
		CreatedAt:       s.CreatedAt.Format(time.RFC3339),
		UpdatedAt:       s.UpdatedAt.Format(time.RFC3339),
	}
}
