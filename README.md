# Zambia SkillBridge

**Learn. Build. Grow.** A Flutter (Android) prototype that connects skilled Zambian workers with people who need them.

> **Status of this build:** all source code, tests and documentation are written, and every file passes a Dart syntax parse. The code has **not** been compiled, analysed or run, because the environment it was written in had no Flutter or Dart SDK and could not download one. Run the commands in "Getting started" before you demo it, and expect a handful of small compile fixes on the first `flutter analyze`.

## Requirements

- Flutter 3.24 or newer (Dart 3.5 or newer, see `pubspec.yaml`)
- Android SDK and an emulator or phone

## Getting started

This repository contains the Dart source (`lib/`, `test/`, `pubspec.yaml`) but not the generated `android/` folder. Create it once, inside this folder:

```bash
flutter create . --platforms=android --project-name zambia_skillbridge
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter create .` keeps the existing `lib/` and `pubspec.yaml`. If it replaces `lib/main.dart`, restore it from this repo.

Optional debug APK: `flutter build apk --debug`

Photo picking uses `image_picker`. On Android 13 and newer it uses the system photo picker and needs no extra permission entries.

## What the app does

Two experiences in one app, chosen at onboarding and switchable in **Profile > Demo role**:

- **Client:** search and filter workers, view profiles, save favourites, post jobs, review applicants, request services, message, review completed work.
- **Worker:** six-step profile wizard, portfolio with real photos from the gallery, find and apply for jobs, manage bookings, take quizzes, earn badges, read certification guidance.

"Continue as demo" on the sign-in screen opens fictional sample data (worker David Mwamba, client Natasha Phiri).

### Screens

Splash, onboarding (Show it, Prove it, Grow it), role selection, sign in and registration, worker setup wizard, worker dashboard, client dashboard, browse trades, search results, public worker profile (About, Portfolio, Reviews), portfolio manager and project editor, post a job, job discovery, job details, applicants, service request, booking details, My Jobs and bookings, messaging (list and chat), rating and review, quizzes, skills and badges, certification pathways, notifications, favourites, profile and settings, edit details, availability.

## Architecture

```
lib/
  main.dart, app.dart
  core/        constants, theme (SB design tokens), routing (GoRouter), format helpers, shared widgets
  models/      typed models with JSON (de)serialisation
  data/
    demo/      seed data with stable ids
    content/   quiz questions and certification content
    local/     LocalStore (SharedPreferences) and MediaStore (photos in app storage)
    repositories/  auth, search and sync interfaces, plus pure business rules (rules.dart)
  state/       Riverpod AppController: the single place that changes and saves data
  features/    one folder per area; widgets only show state and call the controller
```

- **State:** Riverpod `NotifierProvider`. Every change is saved straight to local storage.
- **Routing:** GoRouter with named routes and a `StatefulShellRoute` for the five bottom tabs. The middle tabs depend on role (Browse / Post Job for clients, Find Jobs / My Work for workers).
- **Replaceable services:** `AuthRepository`, `WorkerSearchRepository`, `SyncService`, `LocalStore`. Swap the provider override to plug in a real backend.
- **Business rules** (rating maths, badge rules, booking transitions, quiz scoring) are plain Dart in `data/repositories/rules.dart` and are unit tested.

## Offline behaviour

Everything is local-first: profiles, portfolio metadata, favourites, jobs, applications, bookings, messages, reviews, quiz attempts and settings are stored on the device and work without a connection. An amber banner shows when the phone reports no network. The app tracks each local change in a "saved on this device only" list. `LocalOnlySyncService` always reports that nothing was synchronised, and the UI never says "synced".

## Trust rules built into the app

- No profile shows an official credential. Seeded workers have none, and nothing in the app creates one.
- Profiles keep four things visibly apart: self-declared skills, SkillBridge quiz badges, verified work history (demo data), and official qualifications.
- Quiz badges are app achievements, never certificates. The quiz questions are original and are not TEVETA material.
- The only external link is the TEVETA website address. Other resource links are intentionally unset placeholders.
- Reviews need a completed job or booking with that worker, and only one review per job is allowed.

## Known limitations

- **Not compiled or run yet** (see the status note at the top).
- **No backend.** There is no real marketplace, no multi-device messaging, no push notifications, no payments and no SMS. Jobs, requests and messages exist only on the phone that created them.
- **Demo authentication.** Accounts are stored locally. Passwords are checked for length and then discarded, never stored or sent.
- **Storage.** SharedPreferences is used for all structured data. That is fine at prototype size, but a larger version should move to Hive, Isar or SQLite.
- **No local notification reminders.** `flutter_local_notifications` was left out; in-app notifications only.
- **Share** copies a profile summary to the clipboard (no share sheet package).
- **Video:** workers can attach a link or note to a project. Recording or playing video is not implemented.
- **Distance:** only town-level matching is available. No distances are invented.
- Demo phone numbers are fictional.

## Future backend integration points

- `AuthRepository` for secure sign in and sessions.
- `WorkerSearchRepository` for server-side search.
- `SyncService` and the `pending` change list for synchronisation.
- `MediaStore` for protected cloud storage of photos.
- Messaging: replace the conversation methods in `AppController` with a WebSocket client.
- Production needs access control, server-side validation, abuse reporting and a real privacy policy.

## Tests

```bash
flutter test
```

- `test/rules_test.dart`: phone parsing, quiz scoring, badge rules, booking transitions, demo data integrity, search and filters.
- `test/state_test.dart`: seeding without duplicates, job to application to review flow, duplicate blocking, persistence across launches, account rules, clearing data.
- `test/widget_test.dart`: splash to onboarding, and demo client reaching the dashboard.
