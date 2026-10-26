# Expense Tracker

A personal expense tracker for Android, built with Flutter. All data is stored
locally on the device in SQLite — no account, no internet, no cloud sync.

## Features

- Add, edit and delete expenses (title, amount, category, date, note)
- 8 categories with icons and colours
- Month-by-month view with the month's total
- Swipe to delete, with undo
- Summary tab with a pie chart and per-category totals
- Light and dark mode

## Install

Download [`apk/expense_tracker.apk`](apk/expense_tracker.apk), open it on your
Android phone, and allow "Install unknown apps" when prompted.

## Build from source

```bash
flutter pub get
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.
