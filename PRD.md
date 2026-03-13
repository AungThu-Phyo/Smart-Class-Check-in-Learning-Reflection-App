# PRD - Smart Class Check-in & Learning Reflection App

## Problem Statement
Traditional attendance methods only confirm that a student marked attendance, but they do not reliably prove two key conditions: (1) the student was physically present in the classroom, and (2) the student participated in the learning session. The university needs a lightweight mobile system that verifies on-site presence using GPS and QR scanning, while also collecting short learning reflections before and after class. This improves attendance integrity and provides basic evidence of engagement.

## Target User
- Primary user: University students enrolled in a class session.
- Secondary user: Instructor (reviews attendance and reflection records).
- Optional admin user: Configures session QR and class location settings.

## Feature List
1. Secure student login (Firebase Authentication).
2. View today's classes/sessions and status (`Not Checked In`, `Checked In`, `Completed`).
3. Before Class Check-in:
- Tap `Check-in`.
- Capture GPS location and timestamp.
- Scan session QR code.
- Submit pre-class reflection:
  - Topic from previous class
  - Expected topic today
  - Mood before class (1-5)
4. After Class Completion:
- Tap `Finish Class`.
- Capture GPS location and timestamp again.
- Scan QR code again.
- Submit post-class reflection:
  - What was learned today
  - Feedback about class/instructor
5. Basic history page to view submitted check-in/completion records.
6. Validation rules:
- Must be within allowed session window.
- Must scan valid QR for correct phase (start/end).
- Must be within class geofence tolerance.
- Required text fields cannot be empty.

## User Flow
1. Student logs in.
2. Student opens session list and selects an active class session.
3. Student taps `Check-in`.
4. App captures location, verifies session window, and opens QR scanner.
5. Student scans QR and fills pre-class form.
6. App validates inputs and saves check-in record to Firebase.
7. At end of class, student opens same session and taps `Finish Class`.
8. App captures location and scans end QR.
9. Student completes post-class reflection form.
10. App saves completion record and updates session status to `Completed`.

## Data Fields
### Student Profile
- `uid`
- `studentId`
- `name`
- `email`
- `enrolledClassIds`

### Session Config
- `sessionId`
- `classId`
- `sessionDate`
- `checkInWindowStart`, `checkInWindowEnd`
- `finishWindowStart`, `finishWindowEnd`
- `classLat`, `classLng`
- `geofenceRadiusMeters`
- `qrStartToken`, `qrEndToken`

### Attendance Record
- `attendanceId` (`uid_sessionId`)
- `uid`, `classId`, `sessionId`
- `checkInTimestampClient`, `checkInTimestampServer`
- `checkInLat`, `checkInLng`, `checkInAccuracyMeters`
- `checkInQrValid`
- `previousTopic`, `expectedTopic`, `moodBeforeClass` (1-5)
- `finishTimestampClient`, `finishTimestampServer`
- `finishLat`, `finishLng`, `finishAccuracyMeters`
- `finishQrValid`
- `learnedToday`, `classFeedback`
- `finalStatus` (`none`, `checked_in`, `completed`)

## Tech Stack
- Frontend: Flutter (Android-first for prototype)
- Backend: Firebase
- Firebase Authentication: Student login
- Cloud Firestore: User, session, and attendance data
- Cloud Functions (recommended): Server-side QR/window/geofence validation
- Flutter packages:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`
- `geolocator`, `permission_handler`, `mobile_scanner`

## Prototype Success Criteria
- Student can complete check-in in under 90 seconds under normal network conditions.
- Each valid record stores GPS, QR result, timestamp, and required reflection fields.
- Duplicate check-in/completion for same session is blocked.
- Student can view own status/history for completed sessions.
