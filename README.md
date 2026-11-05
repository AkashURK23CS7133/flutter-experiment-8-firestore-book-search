# Experiment 8 – Searching Information in Google Firestore Database

## Aim

To develop a Flutter application that retrieves information from Google Firestore based on user search input and displays the relevant information on the screen.

## Features

- Book title search field + **Search** button (Enter key also works)
- Firestore query `where('title', isEqualTo: …)`, with a case-insensitive fallback so `python programming` finds `Python Programming`
- Shows title, author, copies available
- Availability chip: *Available* or *Not Available – All Copies Issued* (copies = 0)
- Messages for empty input, *Book not found* and errors

## Source files

`lib/main.dart`, `lib/book_search_page.dart`, `lib/firebase_options.dart`, `lib/firebase_setup_screen.dart`

## Dependencies

`firebase_core`, `cloud_firestore`; dev only: `fake_cloud_firestore`

## Connecting your Firebase project (one-time, manual)

This project ships with a **placeholder** `lib/firebase_options.dart` that contains **no keys**. Until you replace it, the app starts and shows a **"Firebase setup required"** screen. That is expected; it is not a crash.

1. Go to <https://console.firebase.google.com> → **Add project** (any name, e.g. `flutter-lab-urk23cs7133`). Google Analytics is optional.
2. In the project: **Build → Firestore Database → Create database** → pick a location → start in **test mode** (fine for a lab; see *Security* below).
3. Install the Firebase CLI and log in (needs Node.js, which you already have):
   ```powershell
   npm install -g firebase-tools
   firebase login
   ```
4. Install the FlutterFire CLI:
   ```powershell
   dart pub global activate flutterfire_cli
   ```
   If `flutterfire` is "not recognized", add `%LOCALAPPDATA%\Pub\Cache\bin` to your PATH and reopen the terminal.
5. **In this project folder**, run:
   ```powershell
   flutterfire configure --platforms=web,android
   ```
   Pick your Firebase project. This **overwrites** `lib/firebase_options.dart` with your real settings (and creates `android/app/google-services.json` for Android).
6. Create the collection and sample documents shown below (Firestore console → **Start collection**).
7. `flutter run -d chrome`. The real screen now appears instead of the setup screen.

You can reuse the same Firebase project for Experiments 7–10, but you must run `flutterfire configure` **in each project folder** separately.

**Security:** test-mode rules let anyone read/write your database for 30 days. That's OK for a lab demo; delete the project or lock the rules afterwards.

## Firestore data

Create collection **`books`** manually in the Firebase console (the app only reads it). Add documents with auto-ID:

| title (string) | author (string) | copies (number) |
|---|---|---|
| `Python Programming` | `David` | `5` |
| `Artificial Intelligence` | `Andrew` | `7` |
| `Flutter Basics` | `John Smith` | `0` |

Make sure `copies` is type **number**, not string.

## Run

Open a terminal **in this folder**, then:

```powershell
flutter pub get        # download packages
flutter analyze        # should print "No issues found!"
flutter test           # automated tests
flutter run -d chrome  # start the app in Chrome
```

## Expected output

Searching *Python Programming* shows Author **David**, Copies **5**, *Available*.

Screenshots of the running app: [`../OUTPUTS/Experiment_08/`](../OUTPUTS/Experiment_08/)

## Troubleshooting

- **"Firebase setup required" screen**: `lib/firebase_options.dart` is still the placeholder. Do the *Connecting your Firebase project* steps.
- **`permission-denied`**: your Firestore rules block access. Use test mode or allow read/write on the collection for the lab.
- **`flutterfire` not recognized**: add `%LOCALAPPDATA%\Pub\Cache\bin` to PATH.
- **"Unable to determine engine version"**: put real Git first on PATH (see master README).
