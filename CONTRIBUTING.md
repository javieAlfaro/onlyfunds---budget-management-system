# Development and validation

Start with [setup](docs/SETUP.md) and a separate Firebase project with synthetic data.

## Local checks

```sh
flutter pub get
flutter analyze
flutter test
git diff --check
```

These commands are not a claim that every check currently passes. `test/widget_test.dart` contains the generated counter test, while the app uses Firebase. Replace it with meaningful tests and Firebase doubles or emulator-backed integration tests before relying on it as a quality gate.

For changes to records or totals, follow [the demo walkthrough](docs/DEMO.md). Also check empty accounts, invalid amounts, insufficient balance, sign-out/sign-in, multiple users, and a new month. Verify Firestore ownership rules independently of UI behavior.

## Useful next contributions

- Add/test versioned Firestore rules, required indexes, and emulator setup.
- Make balance validation, transaction creation, and summary writes atomic; test concurrent submissions and partial failures.
- Combine savings deduction and saved-total updates.
- Verify deletion of nested records when monthly parent documents do not exist.
- Add service, widget, and integration tests for budgeting flows.
- Evaluate regression on time-ordered data with a baseline and held-out error metrics; distinguish transaction estimates from monthly totals.
- Persist notification settings/history and clarify sample alerts in the UI.
- Add real screenshots and verified platform/build instructions.

Keep documentation synchronized with behavior. Include purpose, validation, and remaining limitations in pull requests. Never commit real financial records, passwords, CLI tokens, or service-account credentials.
