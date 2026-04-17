-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS feedback_entries (
    id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    feedback_type VARCHAR(20) NOT NULL,
    rating INT,
    title VARCHAR(120) NOT NULL,
    message TEXT NOT NULL,
    affected_area VARCHAR(80),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_entries_student_number
        FOREIGN KEY (student_number) REFERENCES students(student_number) ON DELETE CASCADE,
    CONSTRAINT chk_feedback_entries_type
        CHECK (feedback_type IN ('bug', 'usability', 'feature')),
    CONSTRAINT chk_feedback_entries_rating
        CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5))
);

CREATE INDEX IF NOT EXISTS idx_feedback_entries_student_number ON feedback_entries(student_number);
CREATE INDEX IF NOT EXISTS idx_feedback_entries_created_at ON feedback_entries(created_at DESC);

CREATE TABLE IF NOT EXISTS telemetry_events (
    id SERIAL PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL,
    event_name VARCHAR(80) NOT NULL,
    event_category VARCHAR(40) NOT NULL,
    context_payload JSONB,
    screen_name VARCHAR(80),
    app_version VARCHAR(40),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_telemetry_events_student_number
        FOREIGN KEY (student_number) REFERENCES students(student_number) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_telemetry_events_student_number ON telemetry_events(student_number);
CREATE INDEX IF NOT EXISTS idx_telemetry_events_created_at ON telemetry_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_telemetry_events_event_name ON telemetry_events(event_name);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_telemetry_events_event_name;
DROP INDEX IF EXISTS idx_telemetry_events_created_at;
DROP INDEX IF EXISTS idx_telemetry_events_student_number;
DROP TABLE IF EXISTS telemetry_events;

DROP INDEX IF EXISTS idx_feedback_entries_created_at;
DROP INDEX IF EXISTS idx_feedback_entries_student_number;
DROP TABLE IF EXISTS feedback_entries;
-- +goose StatementEnd
