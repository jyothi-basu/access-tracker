# Software Requirements Specification (SRS)

# Project Name
**AccessTracker**
**Version:** 0.2 (MVP Design)
**Author:*** Jyothi Basu

---

# 1. Project Overview
AccessTracker is a community-driven platform that enables users to report, discover, and track accessibility issues in software applications.

The platform aims to provide a centralized knowledge base specifically for accessibility-related issues instead of mixing them with general bug reports found in application stores.

The first version focuses on delivering a complete Minimum Viable Product (MVP). The architecture is intentionally designed to support future expansion, including developer collaboration, notifications, analytics, and additional features.

---

# 2. Problem Statement

Current application stores such as Google Play and Microsoft Store allow users to report problems through reviews. However:
* Accessibility issues are mixed with thousands of unrelated reviews.
* Users cannot easily determine whether an application is accessible before installing it.
* Accessibility issues are difficult for developers to discover and prioritize.
* There is no centralized accessibility knowledge base across applications.
AccessTracker attempts to solve this problem by focusing exclusively on accessibility.

---

# 3. Objectives

* Allow users to report accessibility issues.
* Allow users to search accessibility reports before installing an application.
* Allow community members to verify whether issues still exist.
* Preserve accessibility knowledge across application versions.
* Build a scalable architecture that supports future expansion.

---

# 4. Target Users

## Guest
Can:



* Browse applications.

* Browse accessibility reports.

* View community verifications.

* Search applications.

* Search reports.



Cannot:



* Report issues.

* Submit verifications.



---



## Registered User



Can:



* Register.

* Login.

* Report accessibility issues.

* Edit/Delete own reports.

* Submit community verifications.

* Search applications.

* Search reports.



---



## Administrator



Can:



* Manage users.

* Delete inappropriate reports.

* Delete applications.

* Manage community verifications.



---



# 5. Planned Roles



## Developer (Future Version)



The developer role exists in the system design but is **not implemented in Version 1**.



Future responsibilities include:



* Claim applications.

* Respond to reports.

* Update issue status.

* Publish accessibility fixes.



---



# 6. Technology Stack



## Backend



* Python

* FastAPI



## Database



* MongoDB



## Optional



* Redis (Future Version)



## Security



* Argon2id Password Hashing

* JWT Authentication

* Access Token (30 minutes)

* Refresh Token (7 days)



## Frontend



* Flutter



---



# 7. Project Scope



## Included in MVP



* JWT Authentication

* Refresh Tokens

* Guest/User/Admin roles

* Applications

* Accessibility Reports

* Community Verification

* Search

* Administration



## Excluded from MVP



* Developer workflow

* Google Sign-In

* Email verification

* Notifications

* Redis integration

* File uploads

* Accessibility score



---



# 8. Proposed Architecture



Flutter



↓



FastAPI



↓



Feature Modules



↓



Repository Layer



↓



MongoDB



---



# 9. Backend Structure



```text

app/



&#x20;   auth/

&#x20;   users/

&#x20;   applications/

&#x20;   bugs/

&#x20;   verifications/

&#x20;   admin/



&#x20;   core/

&#x20;       config.py

&#x20;       database.py

&#x20;       dependencies.py

&#x20;       security.py



&#x20;   common/

&#x20;       schemas.py

&#x20;       responses.py

&#x20;       exceptions.py



&#x20;   utils/



&#x20;   main.py

```



---



# 10. Frontend Structure



```text

frontend/



&#x20;   lib/



&#x20;       screens/

&#x20;       services/

&#x20;       models/

&#x20;       providers/

&#x20;       widgets/

&#x20;       constants/

&#x20;       utils/



&#x20;   android/

&#x20;   ios/

&#x20;   linux/

&#x20;   windows/

&#x20;   web/



&#x20;   pubspec.yaml

```



---



# 11. Collections



## Users



Stores:



* User information

* Authentication

* Roles



Roles:



* User

* Developer (Reserved for future implementation)

* Admin



---



## Applications



Stores:



* Application Name

* Platform

* Description



Applications are uniquely identified by:



* Application Name

* Platform



This allows the same application to exist on multiple platforms (Android, Windows, iOS, etc.).



---



## Bugs



Stores:



* Title

* Description

* Application ID

* Reporter ID

* Application Version

* Category

* Severity

* Created Date



### Categories



* Screen Reader

* Keyboard Navigation

* Focus Management

* Forms

* Buttons

* Navigation

* Media

* Other



### Severity



* Low

* Medium

* High

* Critical



---



## Verifications



Stores:



* Bug ID

* User ID

* Application Version

* Status

* Updated Timestamp



Rules:



* One verification per user per bug.

* A new verification replaces the user's previous verification.

* Verification history is not preserved in Version 1.



---



# 12. Community Verification



Instead of simple voting, users verify the current state of an issue.



Possible states:



* Still Exists

* Fixed For Me



Each verification contains:



* Application Version

* Timestamp



Example:



Issue:



TalkBack cannot activate the "Send Money" button.



Reported:



6 months ago



Application Version:



3.4.0



Community Verification



Still Exists



Latest confirmation:

2 days ago

Version 3.6.1



Fixed For Me



Latest confirmation:

3 weeks ago

Version 3.6.0



---



# 13. Planned MVP Features



## Authentication



* Register

* Login

* JWT Authentication

* Refresh Token



## Applications



* Browse applications

* Search applications



## Accessibility Reports



* Create report

* Edit own report

* Delete own report

* View reports



## Community Verification



* Still Exists

* Fixed For Me



## Search



Applications



* Search by application name



Reports



* Search by title

* Search by application

* Search by category

* Search by verification status



## Administration



* Manage users

* Delete inappropriate reports

* Delete applications



---



# 14. Planned Features (Architecture Exists)



* Developer Role

* Developer Verification

* Developer Dashboard

* Claim Application

* Developer Issue Workflow



---



# 15. Future Enhancements



* Google Sign-In

* Email Verification

* Password Reset

* Notifications

* Redis Integration

* Accessibility Score

* Workarounds

* Analytics Dashboard

* Release Notes

* Docker Deployment

* File Uploads



---



# 16. Authentication Design



## Password Hashing



* Argon2id



## Authentication



* JWT



## Access Token



* Valid for 30 minutes.



## Refresh Token



* Valid for 7 days.



## Password Policy



Minimum requirements:



* 8 characters

* One uppercase letter

* One lowercase letter

* One digit



---



# 17. Design Decisions



## Why MongoDB?



Accessibility reports contain flexible information that may vary between applications.



MongoDB allows flexible document structures without rigid relational schemas.



---



## Why Community Verification?



Accessibility issues may be fixed without developers joining the platform.



Community verification keeps reports useful by recording:



* Application version

* User observations

* Verification timestamp



instead of relying solely on developer updates.



---



## Why No Comments?



Comments were intentionally excluded from Version 1 to reduce complexity and ensure completion within the internship timeline.



Community verification provides sufficient information for the MVP.



Threaded discussions may be introduced in future versions if needed.



---



## Why Not Only Google Play Reviews?



General application stores mix accessibility reports with thousands of unrelated reviews.



AccessTracker focuses exclusively on accessibility, creating a searchable knowledge base dedicated to accessibility issues.



---



# 18. Long-Term Vision



AccessTracker should evolve from a simple issue reporting platform into a collaborative accessibility platform where:



* Users report issues.

* Community members verify issues.

* Developers collaborate directly with users.

* Accessibility knowledge is preserved across application versions.

* Applications gradually improve through community feedback.



---



# 19. Current Scope



This document describes Version 0.2 of AccessTracker.



The primary objective is to deliver a production-quality MVP during the internship.



Several planned features—including developer workflows, Google Sign-In, email verification, notifications, Redis integration, and file uploads—have been intentionally deferred. The architecture has been designed so these features can be introduced later without major restructuring.



