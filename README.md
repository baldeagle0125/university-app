# university-app
My final-year project at the South East Technological University.

## Overview
University App is a student-focused platform with:
- A Dockerized server workspace with a Go backend API, React admin portal, PostgreSQL, and local development orchestration.
- A SwiftUI iOS client for student usage.
- Placeholder Android and web client folders for future expansion.
- A static showcase website.

## Project Structure
- [server](server/README.md): Backend, admin frontend, compose stack, and local run instructions.
- [clients/mobile/ios](clients/mobile/ios/README.md): Native iOS app (SwiftUI).
- [clients/mobile/android](clients/mobile/android/README.md): Future Android client.
- [clients/web](clients/web/README.md): Future web client.
- [showcase-web](showcase-web/README.md): Static one-page project showcase website.
- [docs](docs/README.md): Architecture and technical documentation index.

## Quick Start
1. Start frontend + backend + db from the server workspace:

```bash
cd server
make up
```

2. Services:
- Frontend (admin panel): `http://localhost:8080`
- Backend API: `http://localhost:3333`
- Database: `localhost:5432`

3. Run iOS app:

```bash
open clients/mobile/ios/UniversityApp/UniversityApp.xcodeproj
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
- [Server Workspace](server/README.md)
- [Backend Application](server/backend/README.md)
- [Frontend Admin Panel](server/frontend/README.md)
- [iOS Application](clients/mobile/ios/README.md)
- [Android Application](clients/mobile/android/README.md)
- [Web Client](clients/web/README.md)
- [Showcase Website](showcase-web/README.md)
- [Project Documentation](docs/README.md)
