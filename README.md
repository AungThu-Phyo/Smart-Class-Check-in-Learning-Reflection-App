# Smart Class Check-in and Learning Reflection App

## Project description
This project is a Flutter attendance and reflection app for classroom sessions.

Main features:
- Home dashboard with session status and saved history
- Check-in flow with GPS capture, QR validation, and pre-class reflection fields
- Finish-class flow with GPS capture, QR validation, and post-class reflection fields
- Local persistence with SQLite
- Optional Firebase sync to Cloud Firestore using anonymous authentication
- Web deployment on Firebase Hosting

Demo QR values for testing:
- Check-in: SMART-CLASS-START
- Finish class: SMART-CLASS-END

## Setup instructions
1. Install Flutter SDK (stable).
2. Install Node.js (for Firebase CLI).
3. Install Firebase CLI:

```bash
npm install -g firebase-tools
```

4. In the project root, install Flutter dependencies:

```bash
flutter pub get
```

5. If platform folders are missing, generate them once:

```bash
flutter create .
```

6. Login to Firebase CLI:

```bash
firebase login
```

## How to run the app
Run on Chrome (recommended for this project):

```bash
flutter run -d chrome
```

Optional fixed port:

```bash
flutter run -d chrome --web-port 8080
```

Run on another detected device:

```bash
flutter devices
flutter run -d <device-id>
```

Build production web assets:

```bash
flutter build web --release
```

Deploy to Firebase Hosting:

```bash
firebase deploy --only hosting --project smart-class-check-in-n-l-r-app
```

Current hosting URL:
- https://smart-class-check-in-n-l-r-app.web.app

## Firebase configuration notes
Firebase project used by this app:
- Project ID: smart-class-check-in-n-l-r-app

Required Firebase services:
1. Authentication
2. Cloud Firestore
3. Firebase Hosting

Authentication requirements:
1. Enable Firebase Authentication in Console.
2. Enable Anonymous sign-in provider.

Firestore and security:
- This app writes attendance data to the attendance_records collection.
- Firestore rules in firestore.rules require authenticated users and match uid fields.

Hosting configuration:
- firebase.json is configured to serve build/web.
- SPA rewrite is enabled to /index.html.

If Firebase sync is not ready:
- Local SQLite save still works.
- The app shows Firebase init status and last error on the home screen.

## AI Usage Report (Short)
- What AI tools were used:
GitHub Copilot (GPT-5.3-Codex) was used during development.

- What AI helped generate:
AI helped generate Flutter UI scaffolding, QR scanner flow wiring, Firebase bootstrap/error-handling improvements, and deployment/readme command structure.

- What was modified or implemented manually:
I manually adjusted validation behavior, configured Firebase project settings, verified API/auth behavior with live testing, finalized SQLite and Firebase integration behavior, and deployed the production build.
