# Admin Web Portal

React + Vite frontend for the University App Admin Portal.

This service is Dockerized and intended to boot alongside backend and db from the repository root compose stack.

`frontend/src/App.jsx` is the composition root for the admin UI. Reusable pieces live in `frontend/src/components/` so the main app stays readable while still keeping one place for page-level state and API orchestration.

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

## Updating Dependencies

From `frontend/`:

```bash
npm update
npm run build
```

If you add or remove packages explicitly, run `npm install` so `package-lock.json` stays in sync. Commit `package.json` and `package-lock.json` together.

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

## Session Length

Admin staff sessions use JWTs issued by the backend. They currently stay valid for 7 days unless the token is cleared from browser storage or the backend key changes.
