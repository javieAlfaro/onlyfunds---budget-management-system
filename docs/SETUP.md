# Setup and troubleshooting

## Dependencies

Install Flutter with a Dart SDK compatible with `^3.9.0`, then run `flutter doctor` and `flutter pub get` from the repository root. Keep `pubspec.lock` when reproducing the project; upgrading dependencies is a separate change.

## Firebase configuration

The checked-in client configuration identifies the original Firebase project. Use a separate project for local demos rather than assuming access to that backend.

1. Create a project in the [Firebase console](https://console.firebase.google.com/).
2. Enable **Authentication → Sign-in method → Email/Password**.
3. Create a **Cloud Firestore** database and choose its location.
4. Install the [Firebase CLI](https://firebase.google.com/docs/cli) and follow the [FlutterFire setup instructions](https://firebase.google.com/docs/flutter/setup). From the repository root, run:

   ```sh
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. Select your own project and mobile platforms. Verify that `lib/firebase_options.dart` and platform configuration files refer to your project. The Android application ID is currently `com.example.onlyfunds_v1`; the iOS bundle ID in the committed Firebase options is `com.example.onlyfundsV1`.
6. Configure Firestore rules before using the app. All application records live under `users/{uid}`. Restrict access to the authenticated owner, including nested monthly records. This repository contains no rules file, so it does not establish which rules are deployed.

Do not leave a database open in test mode for a shared demo. Use disposable data. Never commit service-account credentials, private keys, or Firebase CLI tokens.

The app creates documents during registration and record entry; there is no migration or seed command. Monthly parent documents may have no fields or may not exist even when their subcollections contain data.

## Launch

```sh
flutter devices
flutter run -d <device-id>
```

Android is the simplest starting point on Windows. iOS requires macOS, Xcode, and Flutter/Firebase platform setup. Configuration in source does not mean either platform has been verified on your machine.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Dependency resolution fails | Confirm Dart satisfies `^3.9.0`. Investigate package constraints before upgrading the lockfile. |
| Email/password registration fails | Enable the Email/Password provider in the selected Firebase project. |
| Firestore returns `permission-denied` | Confirm sign-in and rules permitting owner access to their user document and nested collections. |
| Unsupported Firebase platform | Committed options support Android/iOS only. Configure other platforms and verify plugin compatibility first. |
| Empty dashboard/history | Add income first. These views read the current calendar month. |
| Expense rejected | The expense exceeds the recorded monthly balance. Savings deposits also consume that balance. |
| Prediction unavailable | At least ten expense records are required. Fitting errors or non-positive results can also prevent a prediction. |
| Notification settings reset | Preferences/history are held in memory; persistent storage is not implemented. |

See [development and validation](../CONTRIBUTING.md) for checks. The starter counter test does not validate OnlyFunds.
