# university-app
My final-year project at the South East Technological University.

## Overview
University App is a student-focused platform with:
- A Go backend API for authentication, student profile data, card requests, assignments, QR/barcode verification, and feedback telemetry.
- An iOS SwiftUI client for student usage.
- A static web page for project showcase.

## Project Structure
- [backend](backend/README.md): Go API service, PostgreSQL integration, migrations, and Docker Compose setup.
- [ios](ios/README.md): Native iOS app (SwiftUI).
- [web](web/README.md): Static one-page project website.
- [docs](docs/README.md): Architecture and technical documentation index.

## Quick Start
1. Start backend services:

```bash
cd backend
make up
```

2. Backend API becomes available on `http://localhost:3333`.

3. Run iOS app:

```bash
open ios/UniversityApp/UniversityApp.xcodeproj
```

4. Open web demo page:

```bash
open web/index.html
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
- [Backend Docker Guide](backend/README.Docker.md)
- [iOS Application](ios/README.md)
- [Web Application](web/README.md)
- [Project Documentation](docs/README.md)
