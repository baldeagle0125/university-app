-- +goose Up
-- +goose StatementBegin
ALTER TABLE students
ADD COLUMN course_title VARCHAR(150),
ADD COLUMN date_of_birth DATE,
ADD COLUMN su_position VARCHAR(100);

CREATE TABLE student_memberships (
    id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    membership_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_memberships_student_number
        FOREIGN KEY (student_number) REFERENCES students(student_number) ON DELETE CASCADE,
    CONSTRAINT uq_student_memberships_student_number_name UNIQUE (student_number, membership_name)
);

CREATE INDEX idx_student_memberships_student_number ON student_memberships(student_number);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_student_memberships_student_number;
DROP TABLE IF EXISTS student_memberships;

ALTER TABLE students
DROP COLUMN IF EXISTS course_title,
DROP COLUMN IF EXISTS date_of_birth,
DROP COLUMN IF EXISTS su_position;
-- +goose StatementEnd
