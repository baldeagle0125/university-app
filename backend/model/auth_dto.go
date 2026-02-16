package model

type LoginRequest struct {
	StudentNumber string `json:"student_number"`
	Password      string `json:"password"`
}

type LoginResponse struct {
	Token string `json:"token"`
}
