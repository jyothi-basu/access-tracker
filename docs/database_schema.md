# Database Schema

# Project

**AccessTracker**

Version: 0.1

---

# Overview

AccessTracker uses **MongoDB** as its primary database.

Collections in the MVP:

* Users
* Applications
* Bugs
* Verifications

The schema is intentionally designed to support future features such as developer workflows, notifications, Redis caching, and analytics without requiring major restructuring.

---

# Collection Relationships

```text
Users
   │
   │ reporter_id
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

---

## Verifications

Unique

* (bug_id, user_id)

Indexes

* bug_id
* user_id

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

## Why No Comments Collection?

Comments are intentionally excluded from Version 1.

Community verification provides enough information for the MVP while keeping the system simple.

If richer discussions become necessary, a dedicated Comments collection can be introduced without affecting the existing schema.

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
