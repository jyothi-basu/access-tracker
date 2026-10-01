# AccessTracker

**Backend-focused Python portfolio project | FastAPI | MongoDB | Redis | JWT | Flutter Web**

AccessTracker is a community-driven accessibility bug reporting platform. It helps people discover accessibility issues before relying on an application, submit structured reports, and record environment-specific community verifications.

The project demonstrates production-oriented Python backend engineering: feature-based FastAPI modules, MongoDB data modeling, Redis-backed OTP workflows, Argon2 password hashing, JWT session management, RBAC, ownership enforcement, and a Flutter Web client.

**Status:** MVP feature implementation is complete and locked for presentation. The primary engineering focus is the Python backend; Flutter Web provides the browser client.

## Problem Statement

Accessibility issues are usually mixed into general application reviews and are difficult to search, compare, or prioritize. Users need a focused place to discover accessibility reports before installing or depending on an application, while developers need structured reports that include platform, version, screen reader, severity, reproduction steps, and device context.

AccessTracker addresses this gap with a dedicated accessibility issue knowledge base and community verification workflow.

## MVP Capabilities

### Authentication and Accounts

- Email OTP verification during registration.
- Argon2 password hashing.
- JWT access tokens with a 30-minute lifetime.
- Seven-day refresh tokens with rotation.
- Hashed refresh-token sessions stored in MongoDB.
- Password reset through email OTP.
- Logout and session revocation.

### Bug Reports

- Guest browsing of accessibility reports.
- Search and filtering by title, application, platform, screen reader, and severity.
- Platform-specific application identity.
- Structured bug creation with application selection.
- Bug details and timestamps.
- Owner editing and deletion.
- Admin editing and deletion through backend RBAC.
- My Bugs profile view.

### Community Verifications

- Verification summaries on bug details.
- View all verifications for a bug.
- Add, edit, and delete the authenticated user's own verification.
- My Verifications profile view.
- Verification ownership enforced by the backend.

### Developer Responses

- Developer dashboard for approved application relationships.
- Application-specific bug counts.
- View all responses created by the authenticated developer.
- View all responses for a bug.
- Create, edit, and delete developer responses.
- Multiple developers can respond to the same bug.
- A developer can respond only when their role is `developer` and their application relationship is approved.
- Response ownership is enforced for edit and delete operations.

Developer application submission and approval workflows are intentionally not implemented. Approved relationships are manually inserted into MongoDB for the current MVP demonstration.

## Technology Stack

### Backend

- Python
- FastAPI
- Pydantic
- Synchronous PyMongo
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

The current client targets browser use. Native mobile and desktop clients are deferred.

## Architecture

The backend uses feature-based modules with the following request flow:

```text
FastAPI Routes -> Services -> Repositories -> MongoDB
```

```text
app/
├── auth/
├── applications/
├── bugs/
├── developers/
├── verifications/
├── core/
└── utils/
```

The Flutter client follows the same feature boundary:

```text
access_tracker_frontend/lib/
├── auth/
├── applications/
├── bugs/
├── developers/
├── verifications/
├── home/
├── core/
└── shared/
```

API calls are kept in service classes and consumed through Riverpod providers. Screens use reusable widgets and do not create independent networking clients.

## Security Design

- Passwords are hashed with Argon2 and never stored as plaintext.
- OTPs are temporary Redis records and are protected with application-level hashing.
- Registration data remains temporary until email verification succeeds.
- Refresh tokens are not stored in plaintext; only token hashes are persisted in sessions.
- Access tokens are short-lived and refresh tokens are rotated.
- Bug ownership and administrator permissions are enforced by the backend.
- Verification mutations are restricted to the verification owner.
- Developer response creation requires both the developer role and an approved developer/application relationship.
- Developer response edit and delete operations require ownership.

## API Documentation

Start the backend, then open:

- Swagger UI: `http://localhost:8000/api/v1/docs`
- OpenAPI JSON: `http://localhost:8000/api/v1/openapi.json`
- Health check: `http://localhost:8000/health`

Important route groups include:

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

GET    /api/v1/developers/applications
GET    /api/v1/developers/responses
GET    /api/v1/developers/bugs/{bug_id}/responses
POST   /api/v1/developers/bugs/{bug_id}/responses
PATCH  /api/v1/developers/responses/{response_id}
DELETE /api/v1/developers/responses/{response_id}
```

Application identity is scoped by normalized display name and platform. Frontend users see application names and platforms; application IDs are used internally for exact backend filtering.

## Local Setup

### Prerequisites

- Python 3.11 or newer.
- MongoDB.
- Redis.
- Flutter SDK for the web client.
- A Resend account and configured sender for email delivery.

### Backend

From the repository root:

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

On Windows PowerShell:

```powershell
python -m venv venv
venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload
```

Configure MongoDB, Redis, JWT, Resend, and `FIRST_ADMIN_EMAIL` in `.env`. Never commit `.env` or real credentials.

### Flutter Web

Create `access_tracker_frontend/.env`:

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

For Resend test accounts, email delivery may be limited to authorized recipients. Use a verified sending domain for broader testing.

## Verification Commands

Backend syntax check:

```bash
python -m compileall -q app
```

Frontend checks when the Flutter SDK is available:

```bash
cd access_tracker_frontend
flutter analyze
flutter test
```

## Known MVP Boundaries

- Developer application submission and approval are manual.
- There is no admin dashboard.
- Developer responses are not formal bug-fix verdicts.
- Community verifications remain environment-specific observations.
- Comments, notifications, analytics, moderation, pagination, and native clients are deferred.
- The current frontend is Flutter Web; a future HTML/CSS/TypeScript client may be evaluated separately.

## Portfolio Focus

AccessTracker demonstrates API design, validation, authentication, token lifecycle management, password security, MongoDB data modeling, Redis workflows, email integration, RBAC, ownership enforcement, and maintainable feature-based architecture for Python backend roles.

## Documentation

- [Software Requirements Specification](access_tracker_srs.md)
- [Database schema](database_schema.md)
- [Frontend README](access_tracker_frontend/README.md)
- [License](LICENSE)
