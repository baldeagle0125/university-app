-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS assignments (
    id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned', 'submitted')),
    submission_text TEXT,
    submitted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_assignments_student_number
        FOREIGN KEY (student_number) REFERENCES students(student_number) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_assignments_student_number ON assignments(student_number);
CREATE INDEX IF NOT EXISTS idx_assignments_due_date ON assignments(due_date);
CREATE INDEX IF NOT EXISTS idx_assignments_status ON assignments(status);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_assignments_status;
DROP INDEX IF EXISTS idx_assignments_due_date;
DROP INDEX IF EXISTS idx_assignments_student_number;
DROP TABLE IF EXISTS assignments;
-- +goose StatementEnd
