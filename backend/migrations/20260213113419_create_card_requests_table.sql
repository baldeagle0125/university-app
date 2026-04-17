-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS card_requests (
    id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('new', 'replacement', 'lost')),
    request_reason TEXT,
    request_status VARCHAR(20) NOT NULL CHECK (request_status IN ('pending', 'approved', 'rejected')),
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    processed_by VARCHAR(100),
    admin_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_number) REFERENCES students(student_number) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_card_requests_student_number ON card_requests(student_number);
CREATE INDEX IF NOT EXISTS idx_card_requests_status ON card_requests(request_status);
CREATE INDEX IF NOT EXISTS idx_card_requests_requested_at ON card_requests(requested_at DESC);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_card_requests_requested_at;
DROP INDEX IF EXISTS idx_card_requests_status;
DROP INDEX IF EXISTS idx_card_requests_student_number;
DROP TABLE IF EXISTS card_requests;
-- +goose StatementEnd
