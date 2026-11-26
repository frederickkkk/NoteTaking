# NoteNest

A modern offline note-taking application built with Flutter and SQLite.

## Features

- Create, view, edit, search, and delete notes
- Mark and manage favorite notes
- Organize notes by School, Personal, Work, and Others
- Choose category and pastel note color
- Persistent local storage using `notenest.db`
- Home, Favorites, Categories, and Settings navigation

## Storage

NoteNest uses `sqflite` and stores records in a local SQLite table named `notes`.

## Run on Android

1. Install Flutter and Android SDK tools.
2. Start an Android emulator or connect a physical Android device.
3. Run:

```sh
flutter pub get
flutter run
```

## Validation

```sh
flutter analyze
flutter test
```
