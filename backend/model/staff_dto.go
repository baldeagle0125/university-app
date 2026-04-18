package model

import "time"

type CreateStaffInput struct {
	StaffNumber string `json:"staff_number"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	Role        string `json:"role"`
}

type UpdateStaffInput struct {
	FirstName *string `json:"first_name"`
	LastName  *string `json:"last_name"`
	Email     *string `json:"email"`
	Password  *string `json:"password"`
	Role      *string `json:"role"`
	IsActive  *bool   `json:"is_active"`
}

type StaffResponse struct {
	ID          int    `json:"id"`
	StaffNumber string `json:"staff_number"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	Email       string `json:"email"`
	Role        string `json:"role"`
	IsActive    bool   `json:"is_active"`
	CreatedAt   string `json:"created_at"`
	UpdatedAt   string `json:"updated_at"`
}

func (s *Staff) ToResponse() StaffResponse {
	return StaffResponse{
		ID:          s.ID,
		StaffNumber: s.StaffNumber,
		FirstName:   s.FirstName,
		LastName:    s.LastName,
		Email:       s.Email,
		Role:        s.Role,
		IsActive:    s.IsActive,
		CreatedAt:   s.CreatedAt.Format(time.RFC3339),
		UpdatedAt:   s.UpdatedAt.Format(time.RFC3339),
	}
}
