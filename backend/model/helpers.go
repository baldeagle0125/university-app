package model

import (
	"database/sql"
	"time"
)

func nullStringToPtr(ns sql.NullString) *string {
	if ns.Valid {
		return &ns.String
	}
	return nil
}

func nullTimeToPtr(nt sql.NullTime) *string {
	if nt.Valid {
		str := nt.Time.Format(time.DateOnly)
		return &str
	}
	return nil
}
