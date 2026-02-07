-- +goose Up
-- +goose StatementBegin
ALTER TABLE students
ADD COLUMN program_code VARCHAR(30),
ADD COLUMN card_issued_date DATE,
ADD COLUMN card_expiry_date DATE,
ADD COLUMN profile_photo_url VARCHAR(255),
ADD COLUMN card_status VARCHAR(20) DEFAULT 'active' CHECK (card_status IN ('active', 'expired', 'lost', 'requested', 'none')),
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE students
DROP COLUMN IF EXISTS program_code,
DROP COLUMN IF EXISTS card_issued_date,
DROP COLUMN IF EXISTS card_expiry_date,
DROP COLUMN IF EXISTS profile_photo_url,
DROP COLUMN IF EXISTS card_status,
DROP COLUMN IF EXISTS created_at,
DROP COLUMN IF EXISTS updated_at;
-- +goose StatementEnd
