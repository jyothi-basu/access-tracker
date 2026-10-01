# AccessTracker Software Requirements Specification

**Version:** 1.0 MVP
**Status:** Implemented and locked for presentation
**Author:** Jyothi Basu

## 1. Purpose

AccessTracker is a community-driven platform for reporting, discovering, and verifying accessibility issues in software applications.

The MVP provides a focused accessibility knowledge base instead of mixing accessibility issues into general application reviews. It is implemented as a FastAPI backend with a Flutter Web client.

## 2. Problem Statement

Accessibility issues are difficult to discover in general application reviews because they are mixed with unrelated feedback and often lack structured technical context. Users need to know about accessibility issues before relying on an application. Developers need structured reports that can be searched, reproduced, and answered.

AccessTracker addresses this problem with structured reports containing application, platform, version, screen reader, severity, behavior, reproduction, and device information.

## 3. Objectives

- Allow guests to browse accessibility bug reports.
- Allow registered users to create and manage their own bug reports.
- Allow the community to record environment-specific verification results.
- Provide secure authentication and account recovery.
- Allow approved developers to respond to bugs belonging to their applications.
- Demonstrate maintainable, feature-based backend architecture.

## 4. Target Users and Permissions

### Guest

Guests can:

- Browse and search bug reports.
- View bug details.
- View community verifications.
- View developer responses.

Guests cannot create bugs, submit verifications, or submit developer responses.

### Registered User

Registered users can:

- Register and verify their email.
- Log in and recover their password.
- Create, edit, and delete their own bugs.
- Submit, edit, and delete their own verifications.
- Browse and search applications and bug reports.

### Administrator

Administrators can edit and delete bug reports through backend RBAC. An administrator dashboard and broader moderation tools are deferred.

Administrators do not receive ownership permissions for other users' verifications or developer responses.

### Developer

A developer must satisfy both conditions:

1. The authenticated user's `users.role` is `developer`.
2. An approved `developer_applications` relationship exists for the bug's application.

Developers can:

- View approved application summaries and bug counts.
- View all responses they created.
- Respond to bugs belonging to approved applications.
- Edit and delete only their own developer responses.

Multiple developers may represent one application, and one developer may represent multiple applications. Multiple developers may respond to the same bug.

## 5. Technology Stack

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

The MVP targets browser use. Native Android, iOS, Windows, macOS, and Linux clients are deferred.

## 6. Functional Requirements

### Authentication

- Registration requires username, email, and password.
- Registration requires email OTP verification before the user is persisted.
- Passwords are hashed with Argon2.
- Login returns a 30-minute access token and a seven-day refresh token.
- Refresh sessions store refresh-token hashes in MongoDB.
- Refresh tokens are rotated.
- Logout revokes the refresh session.
- Password reset uses email OTP verification.

### Applications

- Applications have a display name and platform.
- Applications are uniquely identified by normalized display name and platform.
- The same display name may exist for different platforms.
- Application IDs are used internally for exact relationships and filtering.

### Bug Reports

Bug reports contain:

- Application ID.
- Platform.
- Application version.
- Title.
- Severity.
- Screen reader.
- Actual behavior.
- Expected behavior.
- Optional reproduction steps.
- Optional screen reader version.
- Optional device model.
- Creator ID.
- Created and updated timestamps.

Users can search and filter reports by supported metadata. Bug application filtering uses the exact application ID when supplied; the user-facing UI displays application names and platforms.

### Community Verifications

Verification types are:

- Still present.
- Fixed for me.
- Not present.

Each user can have at most one verification per bug. Only the verification owner may edit or delete it, including when the owner is an administrator.

Community verification is an environment-specific observation. It is not an official determination that a bug is fixed.

### Developer Responses

Developer responses contain:

- Bug ID.
- Application ID derived from the bug.
- Developer ID derived from authentication.
- Response text.
- Created and updated timestamps.

The API resolves the developer username for responses. The client must not provide developer ID, application ID, or bug ID in the request body.

Response endpoints are owned by the Developers feature:

```text
GET    /api/v1/developers/applications
GET    /api/v1/developers/responses
GET    /api/v1/developers/bugs/{bug_id}/responses
POST   /api/v1/developers/bugs/{bug_id}/responses
PATCH  /api/v1/developers/responses/{response_id}
DELETE /api/v1/developers/responses/{response_id}
```

## 7. Non-Functional Requirements

- Backend features follow Routes -> Services -> Repositories -> MongoDB.
- Authentication and authorization decisions are enforced by the backend.
- API errors should be returned with clear HTTP status codes and messages.
- Flutter screens use service and provider layers rather than direct HTTP calls.
- Primary interactions should remain keyboard and screen-reader accessible.
- Bug and verification cards use readable vertical layouts with explicit labels.
- The system should preserve platform-specific application identity.

## 8. Architecture

```text
Flutter Web
    |
    v
FastAPI routes
    |
    v
Feature services
    |
    v
Feature repositories
    |
    v
MongoDB / Redis
```

### Backend Structure

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

### Frontend Structure

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

## 9. Data Collections

### users

Stores username, email, Argon2 password hash, role, email verification state, and account timestamps.

Roles are `user`, `developer`, and `admin`.

### applications

Stores display name, normalized name, platform, ownership metadata, and timestamps. Normalized name and platform are unique together.

### bugs

Stores structured accessibility bug reports. `application_id` is stored as a MongoDB `ObjectId`.

### verifications

Stores one user verification per bug, including verification type, application version, optional device information, and timestamps.

### developer_applications

Represents the application-specific relationship between a user and an application:

```text
user X is an approved developer for application Y
```

Fields include user ID, application ID, status, and timestamps. Status values are `pending`, `approved`, and `rejected`.

The MVP does not implement application submission or approval workflows. Approved records are manually inserted for demonstration and testing.

### developer_responses

Stores separate developer response documents. There is intentionally no unique index on `bug_id`, allowing multiple developers to respond to one bug.

Response queries are ordered by `updated_at` descending.

## 10. Security Requirements

- Never store plaintext passwords.
- Never store plaintext refresh tokens.
- Require access authentication for protected operations.
- Enforce bug ownership and administrator permissions in the backend.
- Enforce verification ownership in the backend.
- Require both developer role and approved application relationship before response creation.
- Enforce response ownership for edit and delete operations.
- Do not trust client-supplied developer or application identity fields.

## 11. MVP Scope Status

Implemented:

- Authentication and email OTP flows.
- Applications and application picker.
- Bug creation, browsing, details, editing, and deletion.
- Community verification CRUD and summaries.
- My Bugs and My Verifications.
- Developer dashboard and developer response CRUD.
- Platform-specific application IDs and exact bug filtering.
- Flutter Web application shell and protected navigation.

Deferred:

- Developer application submission form.
- Admin approval/rejection UI and workflow.
- Evidence for developer verification.
- Admin dashboard and user management.
- Comments and discussions.
- Notifications.
- Analytics and moderation tooling.
- Formal bug lifecycle statuses.
- Response version history and soft deletion.
- Pagination and advanced performance work.
- Native mobile and desktop clients.

## 12. Verification and Deployment Notes

Backend local startup:

```bash
uvicorn app.main:app --reload
```

Backend syntax check:

```bash
python -m compileall -q app
```

Frontend checks require a working Flutter SDK:

```bash
cd access_tracker_frontend
flutter analyze
flutter test
```

The MVP is intended for local demonstration and portfolio review. Production deployment would require environment-specific secrets, HTTPS, secure browser token handling, email-domain configuration, monitoring, automated tests, and operational hardening.
