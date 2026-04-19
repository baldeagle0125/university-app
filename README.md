# university-app
My final-year project at the South East Technological University.

## Overview
University App is a student-focused platform with:
- A Go backend API for authentication, student profile data, card requests, assignments, QR/barcode verification, and feedback telemetry.
- A React admin panel frontend.
- An iOS SwiftUI client for student usage.
- A static showcase website.

## Project Structure
- [backend](backend/README.md): Go API service and PostgreSQL integration.
- [frontend](frontend/README.md): Dockerized admin panel (React + Vite).
- [ios](ios/README.md): Native iOS app (SwiftUI).
- [android](android/README.md): Future Android client.
- [web](web/README.md): Future web client.
- [showcase-web](showcase-web/README.md): Static one-page project showcase website.
- [docs](docs/README.md): Architecture and technical documentation index.

## Quick Start
1. Start frontend + backend + db from repository root:

```bash
make up
```

2. Services:
- Frontend (admin panel): `http://localhost:8080`
- Backend API: `http://localhost:3333`
- Database: `localhost:5432`

3. Run iOS app:

```bash
open ios/UniversityApp/UniversityApp.xcodeproj
```

4. Open showcase website:

```bash
open showcase-web/index.html
```

## Core Features
- JWT-based login (`/api/v1/login`)
- Student profile retrieval (`/api/v1/student-info`)
- QR and barcode generation/verification (`/api/v1/qr-code`, `/api/v1/barcode`, `/api/v1/verify`)
- Student card request lifecycle (`/api/v1/card/*`, `/api/v1/admin/card-requests/*`)
- Assignment tracking and submission (`/api/v1/assignments`)
- Feedback and telemetry collection (`/api/v1/feedback`, `/api/v1/telemetry/events`)

## Read More
- [Backend Application](backend/README.md)
- [Frontend Admin Panel](frontend/README.md)
- [iOS Application](ios/README.md)
- [Android Application](android/README.md)
- [Web Client](web/README.md)
- [Showcase Website](showcase-web/README.md)
- [Project Documentation](docs/README.md)
