# Flutter CRUD App — Offline Cache & State Management

Extension of the **Course API integration** assignment (branch
`feature/course-api-integration`). This version keeps every screen exactly the
same and adds, under the hood: **offline support**, **persistent local
storage**, **Provider state management**, a **repository-pattern architecture**,
and **optimistic UI updates**.

**Branch:** `feature/offline-cache-and-state-manangement`
(built on top of `feature/course-api-integration`)

---

## Tools and packages used

| Package | Version | Purpose |
|---|---|---|
| `http` | ^1.2.0 | REST API calls (GET / POST / PUT / DELETE) |
| `provider` | ^6.0.0 | State management (replaces `setState`) |
| `shared_preferences` | ^2.0.0 | Local storage for the offline cache |

API used: `https://jsonplaceholder.typicode.com/posts` (first 10 items shown as "courses").

---

## Architecture

Required flow, with a clean separation of concerns:

```
UI (screens)
   |  reads state / calls methods
State Management (CourseProvider - ChangeNotifier)
   |
Repository (CourseRepository - decides API vs cache)
   |                         |
API Service (HTTP only)    Local Storage (SharedPreferences)
```

Folder layout (only the **courses** part changed; the auth/subjects screens are untouched):

```
lib/
- main.dart                      # wraps the app in ChangeNotifierProvider
- enums.dart                     # ApiState + CourseStatus (loading/success/empty/error)
- models/
  - course_model.dart            # + toJson(id) for cache + copyWith for optimistic updates
  - user.dart  subject.dart  gender.dart   # (unchanged - auth/subjects)
- services/
  - api_service.dart             # HTTP requests ONLY
  - local_storage_service.dart   # read/write the cached course list
- repositories/
  - course_repository.dart       # decides between API and local storage
- providers/
  - course_provider.dart         # UI state + optimistic updates + rollback
- controllers/  validators/      # (unchanged - auth)
- screens/
  - course_list_screen.dart      # now Provider-driven (same UI)
  - course_form_screen.dart      # now Provider-driven (same UI)
  - dashboard / login / registration / detail   # (unchanged)
```

- **API service** only talks HTTP - no caching or UI code.
- **Repository** is the only place that decides where data comes from.
- **Provider** holds UI state and the course list; screens never call the API directly.
- **Screens** just render whatever the provider exposes.

---

## Offline approach (local storage)

After every successful API call the course list is saved to `SharedPreferences`
as JSON, so the cache stays in sync with the server. Reading is **offline-first**
and decided inside the repository:

1. Try the API.
2. **Success** -> overwrite the cache with the fresh data and show it.
3. **Failure** (no internet / server down) -> load the cached list instead.

So with no internet the courses screen still opens and shows the last data it
saw, using the same list UI. (`SharedPreferences` is allowed for simple cases
like this; the storage code is isolated in one file, so switching to Hive or
Sqflite later only means editing `local_storage_service.dart`.)

---

## State management approach (Provider)

`CourseProvider` (a `ChangeNotifier`) replaces all the old `setState` and manages
four states via the `CourseStatus` enum: **loading**, **success**, **empty**,
**error**. UI logic is separated from business logic - the screens only read
`provider.status` / `provider.courses` and call methods like
`provider.deleteCourse(...)`.

---

## Optimistic UI updates

- **Delete:** the card disappears instantly. If the API call fails, it is
  re-inserted at its original position and a red "Delete failed" message shows.
- **Update:** the new values show immediately. If the API call fails, they revert
  to the original (rollback).
- **Create** is not optimistic, because the server assigns the new `id`.

Plus **pull-to-refresh** on the course list (swipe down to reload).

> No existing screen layout, colour, or widget was changed - only the data
> source for the courses moved from `setState` to Provider.

---

## How to run

```
flutter pub get
flutter run
```

---

## Screenshots


### App Screens
![offline save](screenshots/mad3.png)
![seacrh option](screenshots/mad4.png)

