# Backend Docker Guide

## Services
`compose.yaml` defines:
- `server`: Go backend service on port `3333`
- `db`: PostgreSQL service on port `5432`

The backend runs migrations automatically on startup.

## Prerequisites
1. Docker Desktop (or Docker Engine + Compose plugin)
2. Secret files:
	- `backend/secrets/db_password.txt`
	- `backend/secrets/jwt_secret_key.txt`
	- `backend/secrets/qr_secret_key.txt`
3. Environment variables in shell or `.env` file in `backend` directory:
	- `POSTGRES_HOST`
	- `POSTGRES_PORT`
	- `POSTGRES_DB`
	- `POSTGRES_USER`

Typical local values:

```env
POSTGRES_HOST=db
POSTGRES_PORT=5432
POSTGRES_DB=university_app
POSTGRES_USER=postgres
```

## Start

```bash
docker compose up --build
```

Backend API: `http://localhost:3333`

## Stop

```bash
docker compose down
```

Remove containers + volumes:

```bash
docker compose down -v
```

## Logs

```bash
docker compose logs -f
```

## Common Issues
- Missing secret file: check `backend/secrets/*.txt` names and paths.
- DB connection failure: verify `POSTGRES_*` values and that `POSTGRES_HOST=db` for Compose mode.
- Non-admin access to admin card endpoints: ensure you are authenticated via `POST /api/v1/staff/login` with a staff account that has `role='admin'`.
- Port collision on `3333` or `5432`: stop conflicting local services or remap ports in `compose.yaml`.
