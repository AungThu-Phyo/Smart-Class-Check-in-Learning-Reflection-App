# Smart Class Check-in & Learning Reflection App

A Flutter mobile application that allows university students to check in to class and reflect on their learning experience.

---

## Features

### 1. Class Check-in (Before Class)
Students press **Check In**, and the app:
- Records their **GPS location** and timestamp
- Opens a **QR code scanner** to scan the class QR code
- Presents a **pre-class reflection form** with:
  - What topic was covered in the previous class
  - What topic they expect to learn today
  - **Mood selection** (1–5 emoji scale)

| Score | Mood | Emoji |
|-------|------|-------|
| 1 | Very negative | 😡 |
| 2 | Negative | 🙁 |
| 3 | Neutral | 😐 |
| 4 | Positive | 🙂 |
| 5 | Very positive | 😄 |

### 2. Class Completion (After Class)
Students press **Finish Class**, and the app:
- Opens a **QR code scanner** to scan the class QR code
- Records their **GPS location**
- Presents a **post-class reflection form** with:
  - What they learned today
  - Feedback about the class or instructor

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile framework | Flutter (Dart) |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Location | Geolocator |
| QR scanning | Mobile Scanner |
| State management | Provider |

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config (replace with real values)
├── models/
│   ├── app_user.dart            # Student user model
│   ├── class_session.dart       # Class session model
│   ├── check_in_record.dart     # Pre-class check-in record
│   └── completion_record.dart   # Post-class completion record
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper
│   ├── firestore_service.dart   # Firestore CRUD operations
│   └── location_service.dart    # GPS location wrapper
├── providers/
│   ├── auth_provider.dart       # Authentication state
│   └── check_in_provider.dart  # Check-in/completion flow state
├── screens/
│   ├── splash_screen.dart       # Loading / auth redirect
│   ├── login_screen.dart        # Sign in / register
│   ├── home_screen.dart         # Class list
│   ├── check_in_screen.dart     # Pre-class check-in flow
│   ├── completion_screen.dart   # Post-class completion flow
│   ├── qr_scanner_screen.dart   # Camera QR scanner
│   └── history_screen.dart      # Past check-ins & completions
└── widgets/
    ├── mood_selector.dart        # Emoji mood picker (1–5)
    └── class_card.dart           # Class list item card
```

---

## Firestore Data Model

```
users/{uid}
  email, displayName, studentId

classSessions/{sessionId}
  name, courseCode, instructorName, room, scheduledAt, durationMinutes, qrCode

checkIns/{checkInId}
  studentId, classSessionId, timestamp, latitude, longitude,
  previousTopic, expectedTopic, moodScore (1–5)

completions/{completionId}
  studentId, classSessionId, timestamp, latitude, longitude,
  learnedToday, feedback
```

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.3.0
- A Firebase project with **Authentication** and **Firestore** enabled
- Android Studio / Xcode for platform builds

### 1. Clone & install dependencies
```bash
git clone <repo-url>
cd Smart-Class-Check-in-Learning-Reflection-App
flutter pub get
```

### 2. Configure Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Link your Firebase project (generates lib/firebase_options.dart)
flutterfire configure
```

Also add:
- `android/app/google-services.json` (download from Firebase Console)
- `ios/Runner/GoogleService-Info.plist` (download from Firebase Console)

> ⚠️ Both files are in `.gitignore` — never commit them to source control.

### 3. Set Firestore security rules
Copy `firestore.rules` to your Firebase Console → Firestore → Rules, or deploy via CLI:
```bash
firebase deploy --only firestore:rules
```

### 4. Run the app
```bash
flutter run            # Connects to a running emulator or device
flutter run -d chrome  # Web (experimental)
```

### 5. Run tests
```bash
flutter test
```

---

## Adding Class Sessions (Seeding Data)

Class sessions are managed by instructors/admins via the Firebase Console or Admin SDK.

Example Firestore document under `classSessions/`:
```json
{
  "name": "Introduction to Programming",
  "courseCode": "CS101",
  "instructorName": "Dr. Smith",
  "room": "Lab 3B",
  "scheduledAt": "2024-03-15T09:00:00.000",
  "durationMinutes": 90,
  "qrCode": "CS101-2024-03-15-0900"
}
```

The `qrCode` field should match the value encoded in the physical QR code displayed in the classroom.

---

## Security

- Firestore rules enforce that students can only read/write their own records.
- Check-in and completion records cannot be updated or deleted by students.
- Firebase API keys are stored in `.gitignore`-excluded config files.
- All data is validated both client-side and via Firestore security rules.