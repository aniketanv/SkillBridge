# SkillBridge Mobile App

This directory contains the Flutter source code for the SkillBridge application.

## 📁 Directory Structure

- **`lib/features/`**: The core of the app, organized by feature.
  - `auth/`: Authentication logic and screens.
  - `skills/`: Skill listing, details, and creation.
  - `chat/`: Messaging functionality.
  - `bookings/`: Session management.
  - `home/`: Main discovery feed.
  - `profile/`: User profile management.
  - `admin/`: Administrative tools.
- **`lib/models/`**: Data models for Firestore synchronization.
- **`lib/theme/`**: App-wide styling and Material 3 theme configuration.
- **`lib/router/`**: Navigation logic using `GoRouter`.
- **`assets/`**: Static images and iconography.

## 🛠 Feature Breakdown

### Authentication
Implemented using `FirebaseAuth`. It includes a custom `AuthRepository` for managing user state and a `redirect` logic in the router to ensure only authenticated users access the main app.

### Skills Marketplace
Users can post skills with descriptions and images. The `SkillsRepository` handles fetching listings from Firestore with support for filtering and searching.

### Communication
Real-time chat is implemented using Firestore snapshots, allowing for instant message delivery and read receipts (extensible).

### State Management
We use **Riverpod 2.0** with the `@riverpod` annotation generator. This provides:
- Compile-time safety.
- Easy testing through provider overrides.
- Minimal boilerplate.

## ⚙️ Development Commands

- **Run build runner**:
  ```bash
  flutter pub run build_runner build
  ```
- **Watch mode (automatic code gen)**:
  ```bash
  flutter pub run build_runner watch
  ```
- **Project cleanup**:
  ```bash
  flutter clean
  flutter pub get
  ```

## 🔗 Links
- [Root README](../README.md) for project overview.
