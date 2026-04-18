-- +goose Up
-- +goose StatementBegin
INSERT INTO staff (
    staff_number,
    first_name,
    last_name,
    email,
    password_hash,
    role,
    is_active
)
VALUES
    ('ST00001', 'Amelia', 'Wright', 'amelia.wright@university.local', '$2a$10$7n0ZFSI5xCJbxN7rEH8DA.ZJVhfacRYOD3PkwWLzmud1GCi8NKMRq', 'admin', TRUE),
    ('ST00002', 'Noah', 'Kim', 'noah.kim@university.local', '$2a$10$7n0ZFSI5xCJbxN7rEH8DA.ZJVhfacRYOD3PkwWLzmud1GCi8NKMRq', 'staff', TRUE)
ON CONFLICT (staff_number) DO NOTHING;

INSERT INTO students (
    student_number,
    first_name,
    last_name,
    email,
    password_hash,
    program_code,
    course_title,
    date_of_birth,
    su_position,
    card_issued_date,
    card_expiry_date,
    profile_photo_url,
    card_status
)
VALUES
    ('S202401', 'Liam', 'Turner', 'liam.turner@student.university.local', '$2a$10$7n0ZFSI5xCJbxN7rEH8DA.ZJVhfacRYOD3PkwWLzmud1GCi8NKMRq', 'CS101', 'BSc Computer Science', DATE '2004-03-15', 'Class Representative', CURRENT_DATE - INTERVAL '120 days', CURRENT_DATE + INTERVAL '245 days', '/static/profile-photos/liam-turner.jpg', 'active'),
    ('S202402', 'Olivia', 'Patel', 'olivia.patel@student.university.local', '$2a$10$7n0ZFSI5xCJbxN7rEH8DA.ZJVhfacRYOD3PkwWLzmud1GCi8NKMRq', 'BUS210', 'BSc Business Analytics', DATE '2003-11-02', 'Debate Society Secretary', CURRENT_DATE - INTERVAL '410 days', CURRENT_DATE - INTERVAL '20 days', '/static/profile-photos/olivia-patel.jpg', 'expired'),
    ('S202403', 'Ethan', 'Nguyen', 'ethan.nguyen@student.university.local', '$2a$10$7n0ZFSI5xCJbxN7rEH8DA.ZJVhfacRYOD3PkwWLzmud1GCi8NKMRq', 'ENG150', 'BEng Mechanical Engineering', DATE '2004-06-28', NULL, NULL, NULL, NULL, 'none'),
    ('S202404', 'Sophia', 'Murphy', 'sophia.murphy@student.university.local', '$2a$10$7n0ZFSI5xCJbxN7rEH8DA.ZJVhfacRYOD3PkwWLzmud1GCi8NKMRq', 'ART330', 'BA Digital Media', DATE '2002-12-09', 'Film Club Chair', CURRENT_DATE - INTERVAL '220 days', CURRENT_DATE + INTERVAL '145 days', '/static/profile-photos/sophia-murphy.jpg', 'lost'),
    ('S202405', 'Mason', 'Garcia', 'mason.garcia@student.university.local', '$2a$10$7n0ZFSI5xCJbxN7rEH8DA.ZJVhfacRYOD3PkwWLzmud1GCi8NKMRq', 'BIO115', 'BSc Biomedical Sciences', DATE '2004-09-21', NULL, NULL, NULL, NULL, 'requested')
ON CONFLICT (student_number) DO NOTHING;

INSERT INTO student_memberships (student_number, membership_name)
VALUES
    ('S202401', 'Coding Society'),
    ('S202401', 'Basketball Club'),
    ('S202402', 'Debate Society'),
    ('S202403', 'Engineering Guild'),
    ('S202404', 'Film Club'),
    ('S202404', 'Photography Collective'),
    ('S202405', 'Wellbeing Society')
ON CONFLICT (student_number, membership_name) DO NOTHING;

INSERT INTO card_requests (
    student_number,
    request_type,
    request_reason,
    request_status,
    requested_at,
    processed_at,
    processed_by,
    admin_notes
)
SELECT
    seed.student_number,
    seed.request_type,
    seed.request_reason,
    seed.request_status,
    seed.requested_at,
    seed.processed_at,
    seed.processed_by,
    seed.admin_notes
FROM (
    VALUES
        ('S202404', 'replacement', 'Previous card was damaged after daily use.', 'approved', NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days', 'ST00001', 'Replacement approved and queued for print.'),
        ('S202405', 'new', 'First campus card request for this semester.', 'pending', NOW() - INTERVAL '3 days', NULL, NULL, NULL),
        ('S202402', 'lost', 'Card was misplaced during travel.', 'rejected', NOW() - INTERVAL '9 days', NOW() - INTERVAL '8 days', 'ST00001', 'Please provide a loss statement and submit again.')
) AS seed(student_number, request_type, request_reason, request_status, requested_at, processed_at, processed_by, admin_notes)
WHERE NOT EXISTS (
    SELECT 1
    FROM card_requests cr
    WHERE cr.student_number = seed.student_number
      AND cr.request_type = seed.request_type
      AND cr.requested_at = seed.requested_at
);

INSERT INTO assignments (
    student_number,
    title,
    description,
    due_date,
    status,
    submission_text,
    submitted_at
)
SELECT
    seed.student_number,
    seed.title,
    seed.description,
    seed.due_date,
    seed.status,
    seed.submission_text,
    seed.submitted_at
FROM (
    VALUES
        ('S202401', 'Data Structures Lab 3', 'Implement and benchmark balanced search trees.', NOW() + INTERVAL '6 days', 'assigned', NULL, NULL),
        ('S202401', 'Systems Programming Reflection', 'Summarize memory safety trade-offs in Go and Rust.', NOW() - INTERVAL '4 days', 'submitted', 'Submitted via LMS with benchmark appendix.', NOW() - INTERVAL '3 days'),
        ('S202402', 'Business Intelligence Dashboard', 'Build KPI dashboard using provided retail dataset.', NOW() + INTERVAL '9 days', 'assigned', NULL, NULL),
        ('S202403', 'Thermodynamics Tutorial Sheet', 'Solve sections 2-5 and upload calculations.', NOW() + INTERVAL '4 days', 'assigned', NULL, NULL),
        ('S202404', 'Interactive Media Prototype', 'Create a low-fidelity prototype for student onboarding.', NOW() - INTERVAL '2 days', 'submitted', 'Prototype link and usability notes attached.', NOW() - INTERVAL '1 days'),
        ('S202405', 'Cell Biology Quiz Prep', 'Complete revision checklist and submit concept map.', NOW() + INTERVAL '7 days', 'assigned', NULL, NULL)
) AS seed(student_number, title, description, due_date, status, submission_text, submitted_at)
WHERE NOT EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.student_number = seed.student_number
      AND a.title = seed.title
      AND a.due_date = seed.due_date
);

INSERT INTO feedback_entries (
    student_number,
    feedback_type,
    rating,
    title,
    message,
    affected_area,
    created_at
)
SELECT
    seed.student_number,
    seed.feedback_type,
    seed.rating,
    seed.title,
    seed.message,
    seed.affected_area,
    seed.created_at
FROM (
    VALUES
        ('S202401', 'feature', 5, 'Calendar Sync Request', 'Please add one-tap calendar export for assignment due dates.', 'assignments', NOW() - INTERVAL '5 days'),
        ('S202402', 'usability', 3, 'Card Status Visibility', 'Card status badge is not obvious on smaller screens.', 'card', NOW() - INTERVAL '7 days'),
        ('S202404', 'bug', NULL, 'Barcode Scan Retry Issue', 'Verification occasionally fails on first attempt and works after retry.', 'qr', NOW() - INTERVAL '2 days')
) AS seed(student_number, feedback_type, rating, title, message, affected_area, created_at)
WHERE NOT EXISTS (
    SELECT 1
    FROM feedback_entries f
    WHERE f.student_number = seed.student_number
      AND f.title = seed.title
      AND f.created_at = seed.created_at
);

INSERT INTO telemetry_events (
    student_number,
    event_name,
    event_category,
    context_payload,
    screen_name,
    app_version,
    created_at
)
SELECT
    seed.student_number,
    seed.event_name,
    seed.event_category,
    seed.context_payload,
    seed.screen_name,
    seed.app_version,
    seed.created_at
FROM (
    VALUES
        ('S202401', 'assignment_list_viewed', 'navigation', '{"result_count": 2, "source": "tab_bar"}'::jsonb, 'AssignmentsView', '1.0.0', NOW() - INTERVAL '1 day'),
        ('S202402', 'card_request_created', 'card', '{"request_type": "lost", "step_count": 3}'::jsonb, 'CardRequestView', '1.0.0', NOW() - INTERVAL '10 days'),
        ('S202404', 'feedback_submitted', 'feedback', '{"feedback_type": "bug", "has_rating": false}'::jsonb, 'FeedbackView', '1.1.0', NOW() - INTERVAL '2 days'),
        ('S202405', 'profile_loaded', 'navigation', '{"memberships": 1, "has_photo": false}'::jsonb, 'ProfileView', '1.1.0', NOW() - INTERVAL '8 hours')
) AS seed(student_number, event_name, event_category, context_payload, screen_name, app_version, created_at)
WHERE NOT EXISTS (
    SELECT 1
    FROM telemetry_events te
    WHERE te.student_number = seed.student_number
      AND te.event_name = seed.event_name
      AND te.created_at = seed.created_at
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM telemetry_events
WHERE student_number IN ('S202401', 'S202402', 'S202403', 'S202404', 'S202405');

DELETE FROM feedback_entries
WHERE student_number IN ('S202401', 'S202402', 'S202403', 'S202404', 'S202405');

DELETE FROM assignments
WHERE student_number IN ('S202401', 'S202402', 'S202403', 'S202404', 'S202405');

DELETE FROM card_requests
WHERE student_number IN ('S202401', 'S202402', 'S202403', 'S202404', 'S202405');

DELETE FROM student_memberships
WHERE student_number IN ('S202401', 'S202402', 'S202403', 'S202404', 'S202405');

DELETE FROM students
WHERE student_number IN ('S202401', 'S202402', 'S202403', 'S202404', 'S202405');

DELETE FROM staff
WHERE staff_number IN ('ST00001', 'ST00002');
-- +goose StatementEnd
