# hisobai

HisobAI - personal finance manager and AI assistant

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Web

Drift's web database requires `web/sqlite3.wasm` and `web/drift_worker.js`.
Keep both files in sync with the Drift version in `pubspec.lock` when upgrading
Drift. The web server must serve `.wasm` files with the `application/wasm`
content type; Flutter's development server does this automatically.
