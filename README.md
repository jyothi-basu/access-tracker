# AccessTracker

**Backend-focused Python portfolio project | FastAPI | MongoDB | Redis | JWT | Flutter Web**

AccessTracker is a community-driven accessibility bug reporting platform. Users can discover accessibility issues, report bugs, and submit community verification results showing whether an issue is still present or has been fixed.

This is a backend-focused portfolio project built around a FastAPI service, MongoDB persistence, Redis-backed OTP workflows, JWT authentication, and a Flutter Web client.

The project demonstrates how to design and implement a structured API-backed product, including authentication, password security, token lifecycle management, ownership enforcement, RBAC, email verification, and community-driven data workflows.

**Current status:** MVP implemented and ready for local demonstration. The primary engineering focus is the Python backend; Flutter Web provides the client experience.

## Problem Statement

Accessibility issues are often reported through general application-store reviews alongside thousands of unrelated comments. This creates four practical problems:

- Users cannot easily determine whether an application is accessible before installing it.
- Accessibility reports are difficult to search and compare across applications and platforms.
- Developers have difficulty discovering and prioritizing accessibility-specific issues.
- Accessibility knowledge is not preserved in a centralized, dedicated knowledge base.

AccessTracker addresses this gap by focusing exclusively on accessibility reports. It gives users a structured place to discover issues, report new problems, and verify whether existing issues are still present or have been fixed.

## Why Review This Project?

This project is designed to demonstrate practical backend engineering skills for Python backend roles:

- Designing feature-based FastAPI modules with routes, services, repositories, and schemas.
- Building secure authentication with Argon2, JWT access tokens, refresh-token rotation, and session revocation.
- Using MongoDB for application data and Redis for expiring OTP workflows.
- Integrating a transactional email provider through a dedicated service layer.
- Applying ownership checks and role-based permissions at the API boundary.
- Keeping frontend networking behind service and provider layers instead of coupling API calls to screens.

## Quick Navigation

- [MVP capabilities](#current-mvp)
- [Backend architecture](#architecture)
- [Security design](#security-design)
- [API documentation](#api-documentation)
- [Local setup](#local-setup)
- [Roadmap](#roadmap)

## Project Goals

- Make accessibility issues easier to discover before users install or depend on an application.
- Capture structured bug reports instead of unsearchable free-form discussions.
- Let the community verify whether reported issues remain reproducible.
- Demonstrate secure authentication, ownership checks, refresh-token sessions, and feature-based architecture.

## Current MVP

### Authentication

- Registration with email OTP verification.
- Login with access and refresh JWT tokens.
- Access token lifetime of 30 minutes.
- Refresh token lifetime of 7 days.
- Refresh-token rotation with hashed tokens stored in MongoDB sessions.
- Argon2 password hashing.
- Password reset through email OTP and a short-lived reset grant.
- Logout and session revocation.

### Bug Reports

- Guest bug feed browsing.
- Search, platform, screen-reader, severity, and sort filters.
- Structured bug creation with application selection.
- Bug details and relative timestamps.
- Owner bug editing and deletion.
- Admin bug editing and deletion through backend RBAC.
- My Bugs profile view.

### Community Verifications

- Verification summary counts on bug details.
- View all verifications for a bug.
- Add, edit, and delete a user-owned verification.
- My Verifications profile view.
- Verification actions are restricted to the verification creator.

## Technology Stack

### Backend

- Python
- FastAPI
- Pydantic
- PyMongo
- MongoDB
- Redis
- Argon2
- PyJWT
- Resend

### Frontend

- Flutter Web
- Riverpod
- Dio
- GoRouter
- Flutter Secure Storage
- Flutter Dotenv

## Architecture

The backend uses feature-based modules with separated routes, services, repositories, and schemas:

```text
app/
├── auth/
│   ├── routes.py
│   ├── service.py
│   ├── repository.py
│   ├── schemas.py
│   ├── email_service.py
│   └── otp_service.py
├── applications/
├── bugs/
├── verifications/
├── core/
└── utils/
```

The Flutter client follows the same feature-oriented approach:

```text
access_tracker_frontend/lib/
├── auth/
├── applications/
├── bugs/
├── verifications/
├── home/
├── core/
└── shared/
```

API calls are kept in service layers and accessed through Riverpod providers. Screens compose providers and reusable widgets rather than creating networking clients directly.

## Security Design

- Passwords are hashed with Argon2 and never stored as plaintext.
- OTP values are hashed with an application pepper before Redis storage.
- Pending registration data is stored temporarily in Redis and is removed after successful verification or failed email delivery.
- Refresh tokens are not stored in plaintext. Only their hashes are persisted in MongoDB sessions.
- Access tokens are short-lived and refresh tokens are rotated.
- Bug mutation permissions are enforced by the backend. Owners can modify their own bugs and admins can modify bugs according to RBAC rules.
- Verification mutation permissions are enforced for the authenticated verification owner.

## API Documentation

When the backend is running:

- Swagger UI: `http://localhost:8000/api/v1/docs`
- OpenAPI JSON: `http://localhost:8000/api/v1/openapi.json`
- Health check: `http://localhost:8000/health`

Important API groups include:

```text
POST   /api/v1/auth/register
POST   /api/v1/auth/register/verify
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout

GET    /api/v1/bugs
GET    /api/v1/bugs/{bug_id}
POST   /api/v1/bugs
PATCH  /api/v1/bugs/{bug_id}
DELETE /api/v1/bugs/{bug_id}
GET    /api/v1/bugs/me

GET    /api/v1/bugs/{bug_id}/verifications
POST   /api/v1/bugs/{bug_id}/verifications
PATCH  /api/v1/bugs/{bug_id}/verifications
DELETE /api/v1/bugs/{bug_id}/verifications
GET    /api/v1/verifications/me
```

## Local Setup

### Prerequisites

- Python 3.11 or newer
- MongoDB
- Redis
- Flutter SDK for the web client
- A Resend account and configured sending domain for email delivery

### Backend

From the repository root:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

On Windows PowerShell, activate the environment with:

```powershell
python -m venv venv
venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload
```

Set MongoDB, Redis, JWT, Resend, and `FIRST_ADMIN_EMAIL` values in `.env` before starting the backend. Never commit `.env` or real credentials.

### Flutter Web

Create `access_tracker_frontend/.env` with:

```env
BACKEND_BASE_URL=http://localhost:8000
APP_ENV=development
```

Then run:

```bash
cd access_tracker_frontend
flutter pub get
flutter run -d chrome
```

The Flutter client appends `/api/v1` to `BACKEND_BASE_URL` automatically.

For Resend accounts operating in test mode, email delivery may be limited to the account's authorized recipient. Configure a verified sending domain before testing registration with arbitrary email addresses.

## Verification

The backend source can be syntax-checked with:

```bash
python -m compileall -q app
```

The Flutter client should be checked locally with:

```bash
flutter analyze
flutter test
```

## Project Documentation

- [Database schema](database_schema.md)
- [Software Requirements Specification](access_tracker_srs.md)
- [Frontend README](access_tracker_frontend/README.md)

## Roadmap

Planned extensions include:

- Admin dashboard.
- Developer workflow and responses.
- Comments and discussions.
- Notifications.
- Better application management.
- Pagination and larger-scale feed performance improvements.
- Additional automated backend and frontend tests.

## Portfolio Focus

AccessTracker demonstrates backend engineering fundamentals that are relevant to remote Python backend roles: API design, validation, authentication, token lifecycle management, password security, MongoDB data modeling, Redis workflows, email integration, RBAC, ownership enforcement, and maintainable feature-based architecture.

## License

See [LICENSE](LICENSE).
