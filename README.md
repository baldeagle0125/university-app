# University App

[![CI](https://github.com/ihormelashchenko/university-app/actions/workflows/ci.yml/badge.svg)](https://github.com/ihormelashchenko/university-app/actions/workflows/ci.yml)

A full-stack university student platform built as a final-year project at South East Technological University (SETU).

[View the project showcase](https://showcase.setu.ie/C00290950/index.html)

> **Project status:** Complete.

## What It Includes

- A native SwiftUI iOS app for students.
- A Go REST API with JWT authentication and PostgreSQL persistence.
- A React admin portal for staff workflows.
- Docker Compose and Kubernetes deployment configurations.
- A static showcase website and the final project documentation.

Android and general-purpose web client directories are reserved for possible future development; they do not currently contain runnable applications.

## Core Features

- Student and staff authentication.
- Student profile and digital ID display.
- Time-limited QR code and barcode generation and verification.
- Student card request and administration workflows.
- Assignment tracking and submission.
- Feedback and telemetry collection.
- Admin management of students, staff, assignments, and card requests.

## Technology

| Area | Technology |
| --- | --- |
| iOS client | SwiftUI |
| Backend | Go 1.26, chi, pgx, goose |
| Admin portal | React 18, Vite 8, Nginx |
| Database | PostgreSQL |
| Local orchestration | Docker Compose |
| Deployment scaffold | Kubernetes, Kustomize |

## Repository Layout

- [`server/`](server/README.md) — backend, admin portal, Docker Compose, and Kubernetes configuration.
- [`clients/mobile/ios/`](clients/mobile/ios/README.md) — native iOS application.
- [`clients/mobile/android/`](clients/mobile/android/README.md) — future Android client placeholder.
- [`clients/web/`](clients/web/README.md) — future web client placeholder.
- [`showcase-web/`](showcase-web/README.md) — static project showcase.
- [`docs/`](docs/README.md) — specifications, reports, presentations, and architecture diagrams.

## Run Locally

### Prerequisites

- Docker Desktop with Docker Compose.
- Xcode for the iOS application.
- Go 1.26 and Node.js 24 or later if running checks outside Docker.

### Server and Admin Portal

From the repository root:

```bash
cd server
make up
```

The first run creates ignored local development secret files from the tracked templates. Replace their placeholder values before using the project anywhere other than local development.

Once the containers are ready:

- Admin portal: <http://localhost:8080>
- Backend API: <http://localhost:3333>
- Health check: <http://localhost:3333/api/v1/health>
- PostgreSQL: `localhost:5432`

Stop the stack with:

```bash
make down
```

### iOS App

Open the Xcode project:

```bash
open clients/mobile/ios/UniversityApp/UniversityApp.xcodeproj
```

The default API URL is configured for the Kubernetes port-forward workflow. See the [iOS README](clients/mobile/ios/README.md) before running against Docker Compose or a physical device.

### Showcase Website

The showcase is static and has no build step:

```bash
open showcase-web/index.html
```

## Verify the Project

Run the repeatable repository checks from `server/`:

```bash
make check
```

This validates the Compose configuration, Go formatting/tests/static analysis, the production admin build, and the showcase JavaScript. GitHub Actions runs the same server checks and also builds the iOS project.

## Demo Accounts

Fresh databases are populated by the seed migration. All demo accounts use password `password123`.

- Admin: `ST00001`
- Staff: `ST00002`
- Students: `S202401` through `S202405`

These credentials are development-only and must not be used in a deployed environment.

## Documentation

- [Server workspace](server/README.md)
- [Backend API and configuration](server/backend/README.md)
- [Admin portal](server/frontend/README.md)
- [iOS application](clients/mobile/ios/README.md)
- [Kubernetes scaffold](server/k8s/README.md)
- [Project documents](docs/README.md)
- [Showcase website](showcase-web/README.md)

## Author

Created by [Ihor Melashchenko](https://ihormelashchenko.com).
