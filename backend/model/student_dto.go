package model

import "time"

type CreateStudentInput struct {
	StudentNumber   string   `json:"student_number"`
	FirstName       string   `json:"first_name"`
	LastName        string   `json:"last_name"`
	Email           string   `json:"email"`
	Password        string   `json:"password"`
	ProgramCode     *string  `json:"program_code"`
	CourseTitle     *string  `json:"course_title"`
	DateOfBirth     *string  `json:"date_of_birth"`
	SUPosition      *string  `json:"su_position"`
	Memberships     []string `json:"memberships"`
	CardIssuedDate  *string  `json:"card_issued_date"`
	CardExpiryDate  *string  `json:"card_expiry_date"`
	ProfilePhotoURL *string  `json:"profile_photo_url"`
	CardStatus      string   `json:"card_status"`
}

type UpdateStudentInput struct {
	StudentNumber   string   `json:"student_number"`
	FirstName       string   `json:"first_name"`
	LastName        string   `json:"last_name"`
	Email           string   `json:"email"`
	Password        string   `json:"password"`
	ProgramCode     *string  `json:"program_code"`
	CourseTitle     *string  `json:"course_title"`
	DateOfBirth     *string  `json:"date_of_birth"`
	SUPosition      *string  `json:"su_position"`
	Memberships     []string `json:"memberships"`
	CardIssuedDate  *string  `json:"card_issued_date"`
	CardExpiryDate  *string  `json:"card_expiry_date"`
	ProfilePhotoURL *string  `json:"profile_photo_url"`
	CardStatus      string   `json:"card_status"`
}

type PartialUpdateStudentInput struct {
	StudentNumber   *string   `json:"student_number"`
	FirstName       *string   `json:"first_name"`
	LastName        *string   `json:"last_name"`
	Email           *string   `json:"email"`
	Password        *string   `json:"password"`
	ProgramCode     *string   `json:"program_code"`
	CourseTitle     *string   `json:"course_title"`
	DateOfBirth     *string   `json:"date_of_birth"`
	SUPosition      *string   `json:"su_position"`
	Memberships     *[]string `json:"memberships"`
	CardIssuedDate  *string   `json:"card_issued_date"`
	CardExpiryDate  *string   `json:"card_expiry_date"`
	ProfilePhotoURL *string   `json:"profile_photo_url"`
	CardStatus      *string   `json:"card_status"`
}

func (i PartialUpdateStudentInput) HasUpdates() bool {
	return i.StudentNumber != nil ||
		i.FirstName != nil ||
		i.LastName != nil ||
		i.Email != nil ||
		i.Password != nil ||
		i.ProgramCode != nil ||
		i.CourseTitle != nil ||
		i.DateOfBirth != nil ||
		i.SUPosition != nil ||
		i.Memberships != nil ||
		i.CardIssuedDate != nil ||
		i.CardExpiryDate != nil ||
		i.ProfilePhotoURL != nil ||
		i.CardStatus != nil
}

type StudentResponse struct {
	ID              int      `json:"id"`
	StudentNumber   string   `json:"student_number"`
	FirstName       string   `json:"first_name"`
	LastName        string   `json:"last_name"`
	Email           string   `json:"email"`
	ProgramCode     *string  `json:"program_code,omitempty"`
	CourseTitle     *string  `json:"course_title,omitempty"`
	DateOfBirth     *string  `json:"date_of_birth,omitempty"`
	SUPosition      *string  `json:"su_position,omitempty"`
	Memberships     []string `json:"memberships"`
	CardIssuedDate  *string  `json:"card_issued_date,omitempty"`
	CardExpiryDate  *string  `json:"card_expiry_date,omitempty"`
	ProfilePhotoURL *string  `json:"profile_photo_url,omitempty"`
	CardStatus      string   `json:"card_status"`
	CreatedAt       string   `json:"created_at"`
	UpdatedAt       string   `json:"updated_at"`
}

func (s *Student) ToResponse() StudentResponse {
	memberships := s.Memberships
	if memberships == nil {
		memberships = []string{}
	}

	return StudentResponse{
		ID:              s.ID,
		StudentNumber:   s.StudentNumber,
		FirstName:       s.FirstName,
		LastName:        s.LastName,
		Email:           s.Email,
		ProgramCode:     nullStringToPtr(s.ProgramCode),
		CourseTitle:     nullStringToPtr(s.CourseTitle),
		DateOfBirth:     nullTimeToPtr(s.DateOfBirth),
		SUPosition:      nullStringToPtr(s.SUPosition),
		Memberships:     memberships,
		CardIssuedDate:  nullTimeToPtr(s.CardIssuedDate),
		CardExpiryDate:  nullTimeToPtr(s.CardExpiryDate),
		ProfilePhotoURL: nullStringToPtr(s.ProfilePhotoURL),
		CardStatus:      s.CardStatus,
		CreatedAt:       s.CreatedAt.Format(time.RFC3339),
		UpdatedAt:       s.UpdatedAt.Format(time.RFC3339),
	}
}
