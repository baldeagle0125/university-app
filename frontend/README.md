# Admin Web Portal

React + Vite frontend for the University App Admin Portal.

This service is Dockerized and intended to boot alongside backend and db from the repository root compose stack.

## Features in current scaffold

- Staff login against `/api/v1/staff/login`
- Admin dashboard shell
- Integrated data fetches for:
  - card requests
  - students
  - assignments
  - feedback
  - telemetry
  - staff
- Card request approve/reject actions

## Local development

```bash
npm install
npm run dev
```

For local Vite dev mode, backend should be running separately.

## Docker (Recommended)

Run full stack from repository root:

```bash
docker compose up --build
```

Frontend URL: `http://localhost:8080`

## Production build (without Docker)

```bash
npm install
npm run build
```
