# Database Schema

# Project

**AccessTracker**

Version: 0.1

---

# Overview

AccessTracker uses **MongoDB** as its primary database.

Collections in the MVP:

* Users
* Sessions
* Applications
* Bugs
* Comments
* Verifications

The schema is intentionally designed to support future features such as developer workflows, notifications, Redis caching, and analytics without requiring major restructuring.

---

# Collection Relationships

```text
Users
   │
   │ reporter_id / user_id
   ▼
 Bugs
   ▲
   │ application_id
Applications

Users
   │
   │ user_id
   ▼
Verifications
   │
   │ bug_id
   ▼
 Bugs

Users
   │
   │ user_id
   ▼
Comments
   │
   │ bug_id
   ▼
 Bugs

Users
   │
   │ user_id
   ▼
Sessions
```

---

# Users Collection

Purpose:

Stores user accounts and authentication information.

## Fields

| Field         | Type     | Required | Description            |
| ------------- | -------- | -------- | ---------------------- |
| _id           | ObjectId | Yes      | Unique identifier      |
| name          | String   | Yes      | Full name              |
| email         | String   | Yes      | Must be unique         |
| password_hash | String   | Yes      | Argon2id password hash |
| role          | String   | Yes      | user, developer, admin |
| is_active     | Boolean  | Yes      | Account status         |
| is_email_verified | Boolean | Yes   | Whether the email address was verified |
| email_verified_at | DateTime | No    | When the email address was verified |
| last_login_at | DateTime | No       | Last successful login  |
| created_at    | DateTime | Yes      | Account creation time  |
| updated_at    | DateTime | Yes      | Last modification time |

## Constraints

* Email must be unique.
* Passwords are never stored in plain text.

## Allowed Roles

* user
* developer *(reserved for future implementation)*
* admin

---

# Sessions Collection

Purpose:

Stores refresh-token-backed login sessions for authenticated users.

Each session represents one active login on one device/client.

## Fields

| Field              | Type     | Required | Description                          |
| ------------------ | -------- | -------- | ------------------------------------ |
| _id                | ObjectId | Yes      | Unique identifier                    |
| user_id            | ObjectId | Yes      | References Users                     |
| refresh_token_hash | String   | Yes      | Hash of the issued refresh token     |
| refresh_jti        | String   | Yes      | Unique token identifier              |
| device_name        | String   | No       | Friendly client label                |
| user_agent         | String   | No       | Browser or client user agent         |
| ip_address         | String   | No       | Session creation IP                  |
| created_at         | DateTime | Yes      | Session creation time                |
| last_used_at       | DateTime | No       | Last refresh or token use time       |
| expires_at         | DateTime | Yes      | Refresh token expiration timestamp   |
| revoked_at         | DateTime | No       | Session revocation timestamp         |

## Constraints

* A user can have multiple active sessions.
* Refresh tokens are stored only as hashes.
* Revoked sessions must not be accepted for refresh.

---

# Applications Collection

Purpose:

Stores applications for which accessibility issues can be reported.

## Fields

| Field       | Type     | Required | Description                                    |
| ----------- | -------- | -------- | ---------------------------------------------- |
| _id         | ObjectId | Yes      | Unique identifier                              |
| name        | String   | Yes      | Application name                               |
| platform    | String   | Yes      | Android, Windows, iOS, macOS, Linux, Web, etc. |
| description | String   | No       | Optional description                           |
| created_at  | DateTime | Yes      | Creation time                                  |
| updated_at  | DateTime | Yes      | Last modification time                         |

## Constraints

Applications are uniquely identified by:

* name
* platform

Example:

* WhatsApp (Android)
* WhatsApp (Windows)

are treated as different applications.

---

# Bugs Collection

Purpose:

Stores accessibility issues reported by users.

## Fields

| Field               | Type     | Required | Description                      |
| ------------------- | -------- | -------- | -------------------------------- |
| _id                 | ObjectId | Yes      | Unique identifier                |
| application_id      | ObjectId | Yes      | References Applications          |
| reporter_id         | ObjectId | Yes      | References Users                 |
| title               | String   | Yes      | Short bug title                  |
| description         | String   | Yes      | Detailed description             |
| application_version | String   | Yes      | Version where issue was observed |
| category            | String   | Yes      | Accessibility category           |
| severity            | String   | Yes      | Bug severity                     |
| status              | String   | Yes      | Open, under_review, resolved     |
| is_deleted          | Boolean  | Yes      | Soft delete marker                |
| created_at          | DateTime | Yes      | Report creation time             |
| updated_at          | DateTime | Yes      | Last update                      |

## Categories

* Screen Reader
* Keyboard Navigation
* Focus Management
* Forms
* Buttons
* Navigation
* Media
* Other

## Severity

* Low
* Medium
* High
* Critical

## Status Values

* open
* under_review
* resolved

---

# Verifications Collection

Purpose:

Allows community members to verify whether a reported issue still exists.

Each user may have only one verification per bug.

Submitting another verification updates the previous one.

## Fields

| Field               | Type     | Required | Description                      |
| ------------------- | -------- | -------- | -------------------------------- |
| _id                 | ObjectId | Yes      | Unique identifier                |
| bug_id              | ObjectId | Yes      | References Bugs                  |
| user_id             | ObjectId | Yes      | References Users                 |
| application_version | String   | Yes      | Version used during verification |
| status              | String   | Yes      | Verification status              |
| updated_at          | DateTime | Yes      | Last verification time           |

## Status Values

* still_exists
* fixed_for_me

## Constraints

Unique:

* (bug_id, user_id)

---

# Comments Collection

Purpose:

Stores comments on accessibility reports.

## Fields

| Field       | Type     | Required | Description           |
| ----------- | -------- | -------- | --------------------- |
| _id         | ObjectId | Yes      | Unique identifier     |
| bug_id      | ObjectId | Yes      | References Bugs       |
| user_id     | ObjectId | Yes      | References Users      |
| comment     | String   | Yes      | Comment body          |
| is_deleted  | Boolean  | Yes      | Soft delete marker    |
| created_at  | DateTime | Yes      | Comment creation time  |
| updated_at  | DateTime | Yes      | Last update time      |

## Constraints

* Comments belong to one bug.
* Comments belong to one user.
* Deleted comments are soft deleted for moderation/history.

---

# Indexes

## Users

Unique

* email

---

## Applications

Unique

* (name, platform)

---

## Bugs

Indexes

* application_id
* reporter_id
* category
* severity
* status
* created_at

---

## Sessions

Unique

* refresh_jti

Indexes

* user_id
* expires_at
* revoked_at

---

## Verifications

Unique

* (bug_id, user_id)

Indexes

* bug_id
* user_id

---

## Comments

Indexes

* bug_id
* user_id
* created_at

---

# Future Collections (Not Part of MVP)

The following collections are reserved for future versions:

## Developer Claims

Stores application ownership requests made by developers.

## Notifications

Stores in-app notifications for users and developers.

## Workarounds

Stores community-submitted accessibility workarounds.

## Analytics

Stores aggregated accessibility statistics.

---

# Design Decisions

## Why Separate Verifications?

Instead of storing verification data inside each bug document, a separate collection allows:

* One verification per user.
* Easy counting of community confirmations.
* Efficient updates.
* Better scalability.

---

## Why Separate Sessions?

Refresh-token sessions are stored separately so the backend can:

* support multiple devices
* revoke individual logins
* rotate refresh tokens safely
* keep access tokens stateless

This is a better fit than storing one refresh token hash directly on the user document.

---

## Future Expansion

The schema has been designed to support:

* Developer workflows
* Accessibility score
* Google Sign-In
* Email verification
* Notifications
* Redis caching
* File uploads

without requiring major database restructuring.
