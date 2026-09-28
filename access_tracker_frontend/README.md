# AccessTracker Flutter Web Client

This directory contains the Flutter Web client for AccessTracker. The primary project focus is the FastAPI backend, while the Flutter client provides an accessible browser interface for authentication, bug browsing, bug reporting, and community verification.

## Features

- Registration and email OTP verification.
- Login, session restoration, refresh, and logout.
- Guest bug browsing.
- Search and filtering for bug reports.
- Bug creation, editing, and deletion.
- Community verification create, edit, delete, and browsing flows.
- My Bugs and My Verifications profile views.
- Accessible vertical layouts with explicit action buttons.

## Configuration

Create `.env` in this directory:

```env
BACKEND_BASE_URL=http://localhost:8000
APP_ENV=development
```

The API client automatically appends `/api/v1` to the configured backend URL.

## Run

```bash
flutter pub get
flutter run -d chrome
```

The FastAPI backend must be running at the configured `BACKEND_BASE_URL`.

## Architecture

```text
lib/
├── auth/
├── applications/
├── bugs/
├── verifications/
├── home/
├── core/
└── shared/
```

Riverpod providers coordinate state, Dio services handle API calls, and reusable widgets keep bug and verification layouts consistent.
