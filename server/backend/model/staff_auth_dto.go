package model

type StaffLoginRequest struct {
	StaffNumber string `json:"staff_number"`
	Password    string `json:"password"`
}
