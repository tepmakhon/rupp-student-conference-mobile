# RUPP Connect — Student mobile app

Flutter frontend for the RUPP Student Conference & Opportunity Platform. This app is for **Students**; Organization and Admin accounts use the web application.

## Stack and structure

Flutter 3.44 / Dart 3.12, Riverpod 2, go_router 16, Dio, secure storage, cached network images, and QR rendering. Features remain under `lib/features/`; shared configuration, routing, theme, and widgets are under `lib/core/`.

- `auth/providers/session_provider.dart`: secure session restoration, student role checks, login, registration, expiry, logout.
- `catalog/services/student_api.dart`: shared API access and cached Riverpod resources. Discovery and notifications load every API page before applying local search/filtering.
- `catalog/screens/`: discovery, details, saved items, My Events, backend-issued tickets.
- `dashboard`, `notifications`, `profile`: student screens and profile editing.
- `core/network/dio_client.dart`: the single Dio instance used by both new and existing services. No credential/token logging.

## Run locally

Install Flutter and the platform toolchains, then run:

```sh
flutter pub get

# Android emulator: 10.0.2.2 reaches the development computer.
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5050/api

# iOS simulator: localhost reaches the development computer.
flutter run --dart-define=API_BASE_URL=http://localhost:5050/api
```

`API_BASE_URL` has **no hardcoded fallback**. Include `/api`; omit a trailing slash. If it is missing or invalid, the app explains the configuration error when connecting. The backend must be running separately; this repository does not modify or start it.

For a **physical Android device**, use the development computer's LAN address, e.g. `http://192.168.1.10:5050/api`, with both devices on the same network. Bind the backend to an accessible interface and allow its port through your firewall. Android cleartext traffic is allowed only in debug builds.

For a **physical iPhone**, prefer a trusted HTTPS development endpoint or HTTPS tunnel to your backend. Local-network access is enabled in the iOS plist for simulator/Bonjour development; there is no blanket insecure-transport exception. An HTTP LAN setup may need a development-only ATS/domain configuration and local-network consent. Do not weaken production transport policy.

On iOS, install CocoaPods when required by Flutter and select a development team in Xcode to run on a device. Secure storage uses the platform Keychain/Android encrypted storage. Android backup is disabled to avoid restoring encrypted credentials without their keys.

## Production

```sh
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://YOUR_BACKEND_HOST/api
```

Replace the placeholder with your deployed backend. Release requests require HTTPS. Provision your own Android application ID, upload keystore/signing configuration, and iOS bundle ID/signing team before distribution. The starter Android project still has a debug signing configuration; it is not a store release configuration. Never put credentials, tokens, or signing secrets in `--dart-define` or commit them.

If the Flutter default NDK installation is incomplete but another compatible NDK is installed, an optional Gradle property is available:

```sh
env 'ORG_GRADLE_PROJECT_rupp.ndkVersion=29.0.14206865' \
  flutter build apk --debug \
  --dart-define=API_BASE_URL=http://10.0.2.2:5050/api
```

Without that override, the project uses Flutter's default NDK.

## Implemented student flows

- Splash and saved-session restoration; invalid, expired, or non-student JWTs return to sign-in. The backend validates the token on API calls; HTTP 401 clears the session and protects every private route.
- Validated sign-in and student registration with university → faculty → major selections; password visibility, loading, and readable errors.
- Home greeting, independent profile/event/opportunity states, upcoming events, content images, cross-catalog search, discovery navigation, retry, and pull-to-refresh.
- Events: search title/description/organizer, category filters, upcoming/next-seven-days/past filters, full details, registration confirmation, My Events, existing-registration detection, full/past/unavailable states.
- Tickets: only the backend ticket response is rendered. QR data must match the returned registration ID and requested event ID and contain a valid student ID. The student registration and event must both remain approved. No ticket data is fabricated.
- Opportunities: search and type filters, images, requirements, deadlines, applications with an optional CV URL, save/unsave, saved opportunities, and existing-application detection. HTTP(S) links supplied within the description/requirements open externally.
- Notifications: unread indicators, individual/read-all actions, refresh, and navigation to the relevant catalog.
- Profile: account/academic information and statistics; edit name, phone, gender, birth date, profile image URL, academic year, and bio; My Events, saved opportunities, about/account information, and logout.
- Safe areas, scrollable keyboard-aware forms, flexible layouts, local event times, empty/error/offline/success states, persistent tab navigation and searches, and cached resources.

Branding follows the accessible [Figma sign-in/home references](https://www.figma.com/design/mwXUip182Qk6iUA1ckRTc4/platform), the existing green/gold theme, and local Figma SVG icons. Live content images come from `bannerImageUrl` and `coverImageUrl`; missing/failed images use a neutral illustration rather than unrelated stock imagery. No presentation/demo data is mixed into live mode. Synthetic content exists only in tests.

## Verified API contracts

Inspected the backend README, `docs/api-map.md`, Express routes/controllers/services, validation schemas, and Prisma schema at commit `9392c4c4419d7919fe597b58a2cf9645ab0d3163`, also verified against GitHub's latest commit. Backend reference: [rupp-student-conference-platform](https://github.com/tepmakhon/rupp-student-conference-platform).

All JSON API responses use `{ success, message, data }`. IDs are serialized strings. Paths below are relative to `API_BASE_URL`:

| Feature | Contract |
| --- | --- |
| Login / registration | `POST /auth/login`, `POST /auth/register`; returns `data.token`, `data.user.role.roleName` |
| Education | `GET /universities`, `/faculties`, `/majors`; arrays with hierarchy IDs |
| Profile | `GET /profile/me`, `PUT /profile/me`; user object with nested `profile`, `student`, `statistics` |
| Event discovery/detail | `GET /events/approved` → `data.events` + pagination; `GET /events/:id` |
| Registration | `POST /events/:id/register`; `GET /events/my-registrations` → array with nested `event` and `registrationStatus` |
| Ticket | `GET /events/:eventId/ticket` → registration info and JSON `qrCode` string |
| Opportunities | `GET /opportunities` → `data.opportunities` + pagination; `GET /opportunities/:id` |
| Save / unsave | `POST /opportunities/:id/save`, `DELETE /opportunities/:id/save`; `GET /opportunities/saved/list` → array with nested `opportunity` |
| Apply | `POST /opportunities/:id/apply` with optional `{cvUrl}`; `GET /applications/me` → `data.applications` + pagination |
| Notifications | `GET /notifications` → `data.userNotifications` + pagination; `PATCH /notifications/:id/read`, `PATCH /notifications/read-all` |

## Remaining API dependencies and limits

- **Password recovery/change, email change, and account deletion:** no supported contracts were found. Recovery explains administrator assistance; no invented requests or success messages.
- **Notification deep links:** notifications contain type/title/message but no target event/opportunity ID. Actions open the appropriate catalog, without guessing an item from its title.
- **External application URL/instructions:** no dedicated fields exist. The app uses the supported in-platform application contract and requirements; it opens only actual HTTP(S) links present in supplied descriptions/requirements.
- **Cancellation/unregistration:** no student cancellation endpoint exists. Existing cancelled registration status is shown in My Events, and re-registration explains that organizer assistance is required; unavailable details show the API error. Registration failures are displayed exactly as returned by the backend.
- **Capacity:** detail `_count.registrations` includes all registration records, whereas backend registration checks exclude cancelled registrations. Accurate remaining active-seat counts need a backend field; the backend remains authoritative on registration.
- **Session refresh:** no refresh-token endpoint exists. An expired session requires sign-in; JWT payload inspection is only a local expiry/role hint, not signature verification.
- **Scale:** discovery currently loads all API pages to keep local filters and search complete. For large catalogs, add server-backed date/organization filters and incremental pagination. Notifications use refresh/read actions, not a live socket connection.
- Native device/end-to-end validation requires a reachable backend and student account. Tests use an injected API service and never submit real registrations or applications.

## Validation

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test

# Optional rendered review images (generated under build/review/):
flutter test --dart-define=CAPTURE_SCREENS=true
```

Tests cover protected session routing, JWT restoration/expiry/logout, authentication validation and readable errors, independent Home failures, event navigation and registration success/failure, persistent search state, valid-ticket gating, and representative screens at **320×568** and **440×956** with larger text.

### Results on this workspace

- `flutter pub get`: passed.
- `dart format lib test`: completed.
- `flutter analyze`: no issues.
- `flutter test`: 20 tests passed.
- Rendered review captures inspected at 320×568 and 440×956 with 150% text scaling, including sign-in, Home, discovery, details, notifications, profile, and profile editing. These are widget-rendered checks; no physical iPhone or Android emulator was connected.
- Android debug APK built at `build/app/outputs/flutter-apk/app-debug.apk` using the documented NDK 29 override. The default NDK 28.2 installation on this machine is incomplete; the existing SDK installation was left intact.
- Live backend sign-in, real registrations/applications, device Keychain/Keystore behavior, external browser handoff, and store signing still require validation against your deployed environment. No backend files were changed and no Git changes were pushed or merged.
