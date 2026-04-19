package handler

import (
	"net/http"
	"strconv"
	"strings"
)

func parseListPagination(r *http.Request) (int, int, error) {
	limit := 25
	offset := 0

	if limitValue := strings.TrimSpace(r.URL.Query().Get("limit")); limitValue != "" {
		parsedLimit, err := strconv.Atoi(limitValue)
		if err != nil || parsedLimit <= 0 {
			return 0, 0, errBadRequest("limit must be a positive integer")
		}

		if parsedLimit > 100 {
			parsedLimit = 100
		}

		limit = parsedLimit
	}

	if offsetValue := strings.TrimSpace(r.URL.Query().Get("offset")); offsetValue != "" {
		parsedOffset, err := strconv.Atoi(offsetValue)
		if err != nil || parsedOffset < 0 {
			return 0, 0, errBadRequest("offset must be a non-negative integer")
		}

		offset = parsedOffset
	}

	return limit, offset, nil
}
