\# Software Requirements Specification (SRS)



\# Project Name



\*\*AccessTracker\*\*



Version: 0.1 (Initial Design)



Author: Jyothi Basu



\---



\# 1. Project Overview



AccessTracker is a community-driven platform that enables users to report, discover, discuss, and track accessibility issues in software applications.



The platform aims to provide a centralized knowledge base specifically for accessibility-related issues instead of mixing them with general bug reports found in application stores.



The first version focuses on delivering a complete Minimum Viable Product (MVP). Future versions may introduce developer collaboration, notifications, analytics, and additional features.



\---



\# 2. Problem Statement



Current application stores such as Google Play and Microsoft Store allow users to report problems through reviews. However:



\* Accessibility issues are mixed with thousands of unrelated reviews.

\* Users cannot easily determine whether an application is accessible before installing it.

\* Accessibility issues are difficult for developers to discover and prioritize.

\* There is no centralized accessibility knowledge base across applications.



AccessTracker attempts to solve this by focusing only on accessibility.



\---



\# 3. Objectives



\* Allow users to report accessibility issues.

\* Allow users to search accessibility reports before installing an application.

\* Allow community members to verify whether issues still exist.

\* Preserve historical accessibility information.

\* Build a scalable architecture that supports future expansion.



\---



\# 4. Target Users



\## Guest



Can:



\* Browse applications

\* Browse accessibility reports

\* Search reports



Cannot:



\* Report issues

\* Comment

\* Verify issues



\---



\## Registered User



Can:



\* Register/Login

\* Report accessibility issues

\* Edit/Delete own reports

\* Comment

\* Verify whether an issue still exists

\* Search reports



\---



\## Administrator



Can:



\* Manage users

\* Remove spam

\* Remove inappropriate reports

\* Manage applications

\* Moderate comments



\---



\# 5. Future Roles (Not MVP)



Developer



Future versions may allow verified developers to:



\* Claim applications

\* Respond to reports

\* Update issue status

\* Publish accessibility fixes



\---



\# 6. Technology Stack



Backend



\* Python

\* FastAPI



Database



\* MongoDB



Optional



\* Redis



Security



\* Argon2id

\* JWT Authentication



Frontend



\* Flutter



\---



\# 7. Proposed Architecture



Flutter



↓



FastAPI Routes



↓



Services



↓



Storage Layer



↓



MongoDB



\---



\# 8. Backend Structure



app/



\* routes/

\* services/

\* repository/

\* models/

\* security/

\* utils/

\* redis/ (optional)

\* config.py

\* main.py



\---



\# 9. Flutter Structure



frontend/lib/



\* screens/

\* models/

\* services/

\* widgets/

\* providers/

\* constants/

\* utils/



\---



\# 10. Collections



\## Users



Stores:



\* User information

\* Authentication

\* Roles



\---



\## Applications



Stores:



\* Application name

\* Platform

\* Description



\---



\## Bugs



Stores:



\* Title

\* Description

\* Application ID

\* Reporter ID

\* Application Version

\* Accessibility Category

\* Severity

\* Created Date



\---



\## Comments



Stores:



\* Bug ID

\* User ID

\* Comment

\* Timestamp



\---



\## Verifications



Stores:



\* Bug ID

\* User ID

\* Application Version

\* Status

\* Updated Timestamp



One verification per user per bug.



\---



\# 11. Community Verification



Instead of simple votes, users verify the current state of an issue.



Possible states:



\* Still Exists

\* Fixed For Me



Each verification includes:



\* Application version

\* Timestamp



This allows users to understand how the issue has changed over time.



Example:



Issue:



TalkBack cannot activate "Send Money" button.



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



\---



\# 12. Planned MVP Features



Authentication



\* Register

\* Login



Applications



\* Browse applications

\* Search applications



Accessibility Reports



\* Create report

\* Edit own report

\* Delete own report

\* View reports



Comments



\* Add comments

\* View comments



Community Verification



\* Still Exists

\* Fixed For Me



Administration



\* Moderate reports

\* Moderate comments

\* Manage applications



\---



\# 13. Features Planned for Future Versions



\* Developer accounts

\* Developer verification

\* Developer dashboard

\* Email verification

\* Password reset

\* Notifications

\* Accessibility score

\* Workarounds

\* File attachments

\* Analytics

\* Redis caching

\* Release notes

\* Docker deployment



\---



\# 14. Design Decisions



\## Why MongoDB?



Accessibility reports contain flexible information that may vary between applications.



MongoDB allows flexible document structures without rigid relational schemas.



\---



\## Why Community Verification?



Accessibility issues may be fixed without developers joining the platform.



Community verification allows reports to remain useful by recording:



\* Current application version

\* User observations

\* Verification timestamps



instead of relying only on developer updates.



\---



\## Why Not Only Google Play Reviews?



General application stores mix accessibility reports with thousands of unrelated reviews.



AccessTracker focuses exclusively on accessibility, creating a searchable knowledge base.



\---



\# 15. Long-Term Vision



AccessTracker should evolve from a simple issue reporting system into a collaborative accessibility platform where:



\* Users report issues.

\* Community members verify issues.

\* Developers engage with users.

\* Accessibility knowledge is preserved across application versions.



\---



\# 16. Current Scope



This document describes Version 0.1 of AccessTracker.



The primary objective is to complete a functional MVP during the internship while designing the architecture to support future expansion.

