# iOS Application

## Overview
Native SwiftUI app for University App users (students).

Main capabilities:
- Login with student number/password
- View profile and digital student ID information
- Generate QR and barcode for verification
- Submit and track card requests
- Track assignments and submit work
- Submit feedback and telemetry events

## Prerequisites
- macOS with Xcode installed
- Running backend API at `http://localhost:3333` (or update app config)

For Minikube testing from your Mac host, expose backend locally:

```bash
kubectl -n university-app port-forward svc/backend 3334:3333
```

## Open and Run

```bash
open clients/mobile/ios/UniversityApp/UniversityApp.xcodeproj
```

In Xcode:
1. Select the `UniversityApp` scheme.
2. Choose an iOS simulator or a connected device.
3. Build and run.

## Backend Configuration
Base URL is defined in:
- `clients/mobile/ios/UniversityApp/UniversityApp/AppConfig.swift`

Default value:

```swift
static let baseURL = "http://localhost:3334"
```

If testing on a physical device, replace `localhost` with your machine's local network IP.

## API Endpoints Used by iOS
- `POST /api/v1/login`
- `GET /api/v1/student-info`
- `GET /api/v1/qr-code`
- `GET /api/v1/barcode`
- `POST /api/v1/verify`
- `POST /api/v1/card/requests`
- `GET /api/v1/card/requests`
- `GET /api/v1/card/status`
- `GET /api/v1/assignments`
- `GET /api/v1/assignments/{id}`
- `POST /api/v1/assignments/{id}/submit`
- `POST /api/v1/feedback`
- `POST /api/v1/telemetry/events`

## Authentication
- Login returns a JWT token.
- Protected requests send `Authorization: Bearer <token>`.
- Unauthorized responses are surfaced to the app as auth errors.
