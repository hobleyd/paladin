# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is Paladin

Paladin is a Flutter eLibrary app for managing ebook collections, optimised for eInk screens and tablets. It syncs metadata and epub files from a self-hosted Calibre web service and stores them locally in SQLite.

## Commands

```bash
# Run the app
flutter run

# Analyze / lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Code generation (required after changing annotated models, providers, or services)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs
```

## Code Generation

Many files have generated counterparts (`.g.dart`, `.freezed.dart`) that must be regenerated after editing annotated source files:

- **Riverpod providers**: classes annotated with `@riverpod` / `@Riverpod(keepAlive: true)` in `lib/providers/` and `lib/repositories/`
- **JSON models**: classes annotated with `@JsonSerializable()` in `lib/models/`
- **Retrofit service**: `lib/services/calibre.dart` (annotated with `@RestApi()`)
- **Freezed models**: `lib/models/version_check.dart`

Never edit `.g.dart` or `.freezed.dart` files directly.

## Architecture

### Layer structure

```
lib/
  models/       # Immutable data classes (json_serializable + manual toMap/fromMap for SQLite)
  services/     # Calibre REST API client (Retrofit + Dio)
  database/     # LibraryDB — the single SQLite database provider
  repositories/ # Per-entity database access providers
  providers/    # Business logic providers (sync orchestration, navigation, theme, etc.)
  screens/      # Full-screen views (Paladin, CalibreSync, BackCover, etc.)
  widgets/      # Composable UI widgets, organised by feature subdirectory
```

### State management

The app uses **Riverpod with code generation** throughout. Key patterns:

- `@Riverpod(keepAlive: true)` for long-lived state (database, network discovery, navigation stack, calibre sync)
- Regular `@riverpod` for providers that can be disposed

### Local database (`LibraryDB`)

`lib/database/library_db.dart` is a `keepAlive` Riverpod provider that owns the SQLite connection via `sqflite_common_ffi`. It is the single source of truth for all local data. Schema DDL is defined as static constants in each repository class and executed by `LibraryDB._createTables()` on first run.

Repositories (e.g. `BooksRepository`, `AuthorsRepository`) implement `DatabaseNotifier` so that `CalibreWS` can trigger `updateStateFromDb()` after a sync completes.

### Calibre sync (`CalibreWS`)

`lib/providers/calibre_ws.dart` orchestrates the full sync lifecycle:

1. `CalibreNetworkService` (Bonsoir mDNS) auto-discovers the Calibre server on the local network; the user can also configure a manual URL via settings.
2. `CalibreWS.synchroniseWithCalibre()` fetches updated book metadata and epub files in batches of 100, then deletes books that have been removed from Calibre.
3. The Calibre REST API is defined in `lib/services/calibre.dart` and injected via `calibreDioProvider`.

### Navigation

Navigation uses Flutter's `Navigator.push()` wrapped by the `NavigatorStack` provider, which maintains a list of route name strings so the app can `popUntil()` a named destination. Version checks against GitHub releases run whenever the user navigates back to the home screen (Android only).

### Collection / Shelf model

`Collection` is the base type for anything that can appear on a shelf (book list filtered by author, series, tag, or the special CURRENT/RANDOM built-in shelves). `CollectionType` drives which query is executed. Each `BookShelf` widget is identified by a numeric `shelfId` from the `shelves` SQLite table.

### Update checking

`lib/providers/update.dart` checks the GitHub releases API (`hobleyd/inkworm`) for a newer APK, Android only.