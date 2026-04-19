# Backend Application

## Overview
The backend is a Go HTTP API built with chi and PostgreSQL.

Responsibilities:
- Authentication and JWT token issuing
- Student profile and student CRUD management
- QR/barcode generation and token verification
- Card request workflow for students and admins
- Assignment listing and submission tracking
- Feedback and telemetry event ingestion

## Tech Stack
- Go `1.26`
- Router: `github.com/go-chi/chi/v5`
- Database: PostgreSQL (`pgx` stdlib + `database/sql`)
- Migrations: `pressly/goose`
- Auth: `golang-jwt/jwt/v5`, `bcrypt`

## Updating Dependencies

From `backend/` you can refresh Go dependencies with:

```bash
go get -u ./...
go mod tidy
```

After that, commit the updated `go.mod` and `go.sum` files together.

## Running the Backend

For frontend + backend + db, run from repository root:

```bash
make up
```

Admin frontend is available at `http://localhost:8080`.

API runs on `http://localhost:3333`.

### Useful Make Targets

Run these from repository root:

```bash
make build
make up
make up-detached
make down
make down-volumes
make logs
make seed-reset
make seed-verify
```

## Demo Mock Data
The backend now includes a seed migration:

- `migrations/20260417190000_seed_demo_data.sql`

Because migrations run automatically at startup, mock data is inserted on first run of a fresh database.

### Reset and Re-seed Demo Data

```bash
make seed-reset
```

This removes the database volume and starts services again so all migrations (including seed data) are reapplied from scratch.

### Verify Seeded Records

```bash
make seed-verify
```

### Demo Login Credentials
All seeded users share password: `password123`

Student accounts:
- `S202401`
- `S202402`
- `S202403`
- `S202404`
- `S202405`

Staff accounts:
- Admin: `ST00001`
- Staff: `ST00002`

## Configuration
The service reads:

Environment variables:
- `POSTGRES_HOST`
- `POSTGRES_PORT`
- `POSTGRES_DB`
- `POSTGRES_USER`

Docker secrets:
- `/run/secrets/db-password`
- `/run/secrets/jwt-secret-key`
- `/run/secrets/qr-secret-key`

Local source secret files:
- `secrets/db_password.txt`
- `secrets/jwt_secret_key.txt`
- `secrets/qr_secret_key.txt`

Example templates are available under `backend/secrets/*.example`.

## Database and Migrations
Migrations run automatically on service startup (`config.RunMigrations`).

Important tables:
- `students`
- `staff`
- `student_memberships`
- `card_requests`
- `assignments`

## API
Base path: `/api/v1`

### Health
- `GET /health`

### Auth
- `POST /login`
	- Body: `{ "student_number": "...", "password": "..." }`
	- Response: `{ "token": "..." }`
- `POST /staff/login`
	- Body: `{ "staff_number": "...", "password": "..." }`
	- Response: `{ "token": "..." }`

JWTs issued by the backend are currently valid for 7 days.

### Student
- `POST /students`
- `GET /students`
	- Query params (admin-only): `search`, `card_status`, `program_code`, `limit`, `offset`
- `GET /students/{id}`
- `PUT /students/{id}`
- `PATCH /students/{id}`
- `DELETE /students/{id}`
- `GET /student-info` (requires Bearer token)

Student write payload fields (create/update/patch):
- `student_number` (required for create/put)
- `first_name` (required for create/put)
- `last_name` (required for create/put)
- `email` (required for create/put)
- `password` (required for create, optional for update/patch)
- `program_code`
- `course_title`
- `date_of_birth` (`YYYY-MM-DD`)
- `su_position`
- `memberships` (array of strings)
- `card_issued_date` (`YYYY-MM-DD`)
- `card_expiry_date` (`YYYY-MM-DD`)
- `profile_photo_url`
- `card_status` (`active|expired|lost|requested|none`)

### QR and Barcode
- `GET /qr-code` (requires Bearer token)
- `GET /barcode` (requires Bearer token)
- `POST /verify`

### Card Requests
- `POST /card/requests` (requires Bearer token)
- `GET /card/requests` (requires Bearer token)
- `GET /card/status` (requires Bearer token)

### Admin Card Requests
- `GET /admin/card-requests` (requires staff Bearer token with `role=admin`)
- `POST /admin/card-requests/{id}/process` (requires staff Bearer token with `role=admin`)

### Admin Assignments
- `GET /admin/assignments` (requires staff Bearer token with `role=admin`)
	- Query params: `status=assigned|submitted|overdue`, `student_number`, `title`, `limit`, `offset`

### Admin Feedback and Telemetry
- `GET /admin/feedback` (requires staff Bearer token with `role=admin`)
	- Query params: `feedback_type`, `student_number`, `limit`, `offset`
- `GET /admin/telemetry/events` (requires staff Bearer token with `role=admin`)
	- Query params: `event_name`, `event_category`, `student_number`, `limit`, `offset`

### Admin Staff Management
- `GET /admin/staff` (requires staff Bearer token with `role=admin`)
	- Query params: `role=admin|staff`, `is_active=true|false`, `limit`, `offset`
- `POST /admin/staff` (requires staff Bearer token with `role=admin`)
- `PATCH /admin/staff/{id}` (requires staff Bearer token with `role=admin`)

Admin processing body:
- `request_status`: `approved|rejected`
- `admin_notes`

### Assignments
- `GET /assignments` (requires Bearer token)
- `GET /assignments/{id}` (requires Bearer token)
- `POST /assignments/{id}/submit` (requires Bearer token)

### Feedback and Telemetry
- `POST /feedback` (requires Bearer token)
- `POST /telemetry/events` (requires Bearer token)

### Static Assets
- `GET /static/profile-photos/*`

Note: Frontend is served by the `frontend` container via Nginx and proxies `/api/*` to backend.

## Admin Portal Frontend

The admin frontend source lives at `../frontend` and is built/served by Docker in the root compose stack.

## Error Behavior
Error responses in newly updated handlers (`student`, `card`) follow JSON:

```json
{
	"error": "message"
}
```

Legacy handlers may still return plain text error bodies.
