# Quiz App — Flutter Frontend Starter

Starter Flutter project wired up against the Flask quiz backend.

## Setup

1. Install Flutter (if not already): https://docs.flutter.dev/get-started/install
2. From this folder:
   ```bash
   flutter pub get
   flutter run
   ```
3. Make sure your Flask backend is running (`python app.py`), and check `lib/config/constants.dart` for the right base URL:
   - Android emulator → `http://10.0.2.2:5000`
   - iOS simulator → `http://127.0.0.1:5000`
   - Physical device → your computer's LAN IP, e.g. `http://192.168.1.5:5000` (phone and computer must be on the same Wi-Fi)

## Project structure

```
lib/
  config/constants.dart      # base URL + endpoint paths
  models/                    # Student, Question, ScoreEntry, QuizResult
  services/
    api_client.dart          # low-level http wrapper, token storage, error normalization
    auth_service.dart        # register/login/logout
    quiz_service.dart        # questions, quiz submission, leaderboard, my-scores
  screens/
    login_screen.dart
    register_screen.dart
    home_screen.dart         # menu: take quiz / leaderboard / my scores
    quiz_screen.dart
    result_screen.dart
    leaderboard_screen.dart
    my_scores_screen.dart
  main.dart                  # checks saved token, routes to login or home
```

## What's already handled

- JWT token + user_id are saved locally (`shared_preferences`) after login and attached automatically to every authenticated request.
- Login screen, register screen, quiz-taking flow, results, leaderboard, and score history are all wired to real endpoints — this runs end-to-end against your current backend, not mock data.
- Quiz screen never displays the `answer` field the backend sends back with each question.
- Errors from the backend are normalized in `ApiClient` since it isn't consistent about `message` vs `msg` vs `status` keys.

## Known backend quirks to be aware of

These come from reading the actual Flask code — nothing to fix here, just things the frontend works around or should watch for:

- **`POST /question`** now expects a single question object (not a list, like an earlier version). `Question.toCreateJson()` in `models/question.dart` matches the current single-object shape.
- **Leaderboard has no names.** `GET /quiz/scores` only returns `student_id`. `LeaderboardScreen` fetches `GET /students` separately and joins by id client-side.
- **`GET /students/<id>`** (the new "private homepage" route added in this backend version) currently has a bug — it tries to iterate over a single `Students` query result as if it were a list, which will throw a 500 rather than returning student + score info. The starter code does **not** call this endpoint yet; it's worth flagging to whoever owns the backend before building a profile screen around it.
- **No refresh/logout endpoint.** Tokens don't appear to expire server-side, and "logout" is just clearing the local token in `AuthService.logout()`.
- **Registration doesn't log you in.** `/register` doesn't return a token, so after signup users are sent back to the login screen to sign in.

## Admin access

The backend now has a real admin tier — `is_admin` is a column on `Students`, embedded in the JWT at login, and enforced server-side with an `@admin_required` decorator on:
- `DELETE /students/<id>`
- `POST /question`
- `DELETE /question/<id>`

**To make your first admin:**
1. Register a normal account through the app (or `POST /register`).
2. From the Flask project folder, run:
   ```bash
   python make_admin.py <username>
   ```
3. Log out and back in on the Flutter app (the `is_admin` flag is only set at login time) — an "Admin Panel" option now appears on the home screen.

The Admin Panel has two tabs:
- **Students** — view and delete accounts, with a confirmation dialog before deleting.
- **Questions** — view/delete existing questions, and add new ones through a form (feeds into `Question.toCreateJson()`, matching the backend's current single-object POST shape).

Non-admin accounts never see the Admin Panel link, and even if they somehow reached it, every action there calls a `@admin_required` endpoint that returns a 403 for non-admin tokens — the UI check is just for a clean experience, not the actual security boundary.

## Not yet built (natural next screens)

- Profile screen using the `/students/<id>` route (now fixed — see backend notes above).
- Bulk question import (e.g. from a CSV) for faster question-bank setup.
