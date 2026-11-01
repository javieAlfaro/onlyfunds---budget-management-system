# OnlyFunds — Budget Management System

A Flutter mobile app for recording daily income and expenses, setting monthly savings goals, and reviewing spending patterns. OnlyFunds brings transaction tracking, Firebase-backed accounts, and experimental expense forecasting into one personal budgeting workflow.

**Built with:** Flutter · Dart · Firebase Authentication · Cloud Firestore · `ml_algo`

Developed by **KADI Group**. Repository contributors include [Javie Alfaro](https://github.com/javieAlfaro) and [Matt Lara](https://github.com/Matt-CRL).

## Features

- **Account management:** email/password registration and sign-in, password recovery, profile updates, and account deletion with reauthentication.
- **Monthly dashboard:** live balance, income, and expense totals through Firestore snapshot streams.
- **Transaction tracking:** record a label, category, amount, and optional description; reject expenses above the available balance.
- **Transaction history:** view the current month's records, sort newest/oldest, and filter income or expenses.
- **Savings goals:** set category-based monthly targets and record contributions against the available balance.
- **Reports and insights:** review category spending, monthly trends, savings rates, and rule-based budget suggestions using up to six months of transaction history.
- **Experimental forecasting:** fit a linear regression model to expense timestamps and amounts after at least ten expense records are available.
- **In-app alerts:** configurable snackbars and dialogs for spending, savings, reminders, and insights, with session-only notification history.

Amounts are displayed in Philippine pesos (₱). Savings contributions are recorded as expenses and increase the monthly saved amount; no actual money is transferred.

## Technical highlights

- Separates authentication, user records, transactions, savings, analytics, and notifications into Dart service classes alongside page widgets.
- Organizes Firestore records by user and calendar month, with a summary document for dashboard totals.
- Uses Firestore transactions for selected summary and balance updates, and `StreamBuilder` for live dashboard and history views.
- Integrates client-side linear regression with insufficient-data and error states. Budget recommendations use spending thresholds rather than a trained recommendation model.

See [architecture and data model](docs/ARCHITECTURE.md) for implementation details and tradeoffs.

## Run locally

### Prerequisites

- Flutter SDK with Dart **3.9 or later within Dart 3.x** (`pubspec.yaml` declares `^3.9.0`).
- Android Studio/Android SDK and an emulator or Android device. iOS development requires macOS and Xcode.
- Your own Firebase project with Email/Password Authentication and Cloud Firestore enabled.

```sh
git clone https://github.com/javieAlfaro/onlyfunds---budget-management-system.git
cd onlyfunds---budget-management-system
flutter doctor
flutter pub get
```

Follow [Firebase setup](docs/SETUP.md) to connect your own backend and configure database access, then run:

```sh
flutter devices
flutter run -d <device-id>
```

The committed Firebase options define Android and iOS configurations. Web, Windows, macOS, and Linux currently throw an unsupported-platform error during Firebase initialization; their generated Flutter folders do not establish working support.

## Explore the app

Register a test account, add income under **Income/Allowance**, record expenses, then open History, Savings, and Reports. Start with [the demo walkthrough](docs/DEMO.md), which includes sample amounts and expected totals.

## Project structure

```text
lib/
├── main.dart                  # Firebase initialization, routes, sign-in entry
├── auth_service.dart          # Authentication and account lifecycle
├── user_service.dart          # Firestore profile records
├── transaction_service.dart   # Monthly transactions and summary streams
├── savings_service.dart       # Savings targets and saved totals
├── ml_analytics_service.dart  # Historical metrics and regression prototype
├── notification_service.dart # In-app alerts and in-memory history
├── pages/                    # Dashboard, history, savings, reports, accounts
└── widgets/                  # Shared interface components
assets/images/                # Onboarding illustrations
docs/                         # Setup, architecture, and demo notes
```

## Status and next steps

This repository presents the current project implementation. It has no documented production release or model accuracy benchmark. Areas for further work include:

- Replace the starter counter test with Firebase-aware unit, widget, and integration tests.
- Version and test Firestore security rules and emulator configuration.
- Make transaction creation, balance validation, and summary updates atomic as a complete operation; combine savings deduction and saved-total updates.
- Evaluate forecasting on time-ordered, aggregated expense data. The current model predicts an individual expense amount at a future timestamp, which is not a validated monthly expense forecast; its confidence score is a heuristic.
- Persist notification preferences/history and add scheduled device notifications if needed.
- Add verified app screenshots and a short recorded demo.

See [development notes](CONTRIBUTING.md) for checks and known limitations.

## Documentation

- [Setup and troubleshooting](docs/SETUP.md)
- [Architecture and Firestore data model](docs/ARCHITECTURE.md)
- [Demo walkthrough](docs/DEMO.md)
- [Development and validation](CONTRIBUTING.md)

## License

No license is currently included in this repository.
