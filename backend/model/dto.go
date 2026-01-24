package model

type StudentResponse struct {
	ID            int    `json:"id"`
	StudentNumber string `json:"student_number"`
	FirstName     string `json:"first_name"`
	LastName      string `json:"last_name"`
	Email         string `json:"email"`
}

func (s *Student) ToResponse() StudentResponse {
	return StudentResponse{
		ID:            s.ID,
		StudentNumber: s.StudentNumber,
		FirstName:     s.FirstName,
		LastName:      s.LastName,
		Email:         s.Email,
	}
}
