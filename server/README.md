# Server Workspace

This folder contains the deployable server-side stack for University App.

## Contents

- [backend](backend/README.md): Go HTTP API, database access, migrations, and static assets.
- [frontend](frontend/README.md): React + Vite admin portal served by Nginx in Docker.
- [compose.yaml](compose.yaml): Local development stack for PostgreSQL, backend, and frontend.
- [Makefile](Makefile): Convenience targets for building, running, resetting, and inspecting the stack.

## Why This Layout

The server code is grouped by runtime boundary instead of by technology alone. The backend and frontend each live in their own service folders, while the compose file and Makefile stay at the workspace root so local development is simple and reproducible.

## Local Development

From this directory:

```bash
make up
```

`make up` runs `make init` automatically. On the first run, this copies the tracked development templates in `backend/secrets/` to ignored local secret files used by Docker Compose. Change those placeholder values before using the stack outside local development.

Useful targets:

```bash
make init
make check
make build
make up
make up-detached
make down
make down-volumes
make logs
make seed-reset
make seed-verify
```

## Runtime Endpoints

- Admin frontend: `http://localhost:8080`
- Backend API: `http://localhost:3333`
- PostgreSQL: `localhost:5432`

## Service Notes

- Backend source: `backend/`
- Backend local secrets: `backend/secrets/*.txt` (ignored)
- Backend secret templates: `backend/secrets/*.txt.example` (tracked)
- Backend static assets: `backend/static/`
- Frontend source: `frontend/`

## Related Docs

- [Root project README](../README.md)
- [Backend service README](backend/README.md)
- [Frontend README](frontend/README.md)
