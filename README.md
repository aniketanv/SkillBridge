# SkillBridge: Peer-to-Peer Skill Sharing Marketplace

SkillBridge is a modern, cross-platform mobile application built with Flutter and Firebase. It empowers users to exchange skills and knowledge within their community through a structured, peer-to-peer marketplace.

## 🚀 Key Features

- **User Authentication**: Secure onboarding via Firebase Auth, supporting email/password and Google Sign-In.
- **Skill Discovery Feed**: A dynamic home feed to browse and search for skills offered by others.
- **Detailed Skill Insights**: In-depth skill descriptions, media previews, and provider profiles.
- **Real-Time Communication**: Integrated Firebase-powered chat for seamless communication between skill seekers and providers.
- **Booking & Scheduling**: Efficient system for scheduling skill sessions.
- **Credit-Based Transactions**: A virtual credit system to facilitate skill exchanges.
- **User Ratings & Reviews**: Accountability and trust-building through a comprehensive review system.
- **Interactive Maps**: Google Maps integration for location-based skill discovery.
- **Admin Capabilities**: Moderation tools for maintaining community standards.

## 🛠 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/) (Material 3)
- **State Management**: [Riverpod](https://riverpod.dev/) (with code generation)
- **Backend/Database**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Cloud Storage, Cloud Messaging)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Maps**: [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- **Theming**: Custom Dark/Light mode support

## 🏗 Architecture & Codebase Design

SkillBridge follows a **feature-first architecture**, ensuring scalability and maintainability.

### Project Structure
- `lib/features/`: Contains feature-specific logic, UI, and data layers (Auth, Skills, Chat, etc.).
- `lib/models/`: Domain models with JSON serialization support.
- `lib/router/`: Centralized routing configuration using GoRouter.
- `lib/theme/`: Comprehensive design system and theme data.
- `lib/utils/`: Common utilities and extensions.

### How it Works
1. **Data Layer**: Repositories (`*_repository.dart`) interact with Firestore and Firebase Auth, handling all external data communication.
2. **Logic Layer**: Controllers (`*_controller.dart`) managed by Riverpod handle the business logic and expose the current state to the UI.
3. **UI Layer**: Consumer Widgets listen to state changes and rebuild reactively, ensuring a smooth user experience.
4. **Code Generation**: Leverages `riverpod_generator` and `build_runner` for type-safe and boilerplate-free state management.

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Firebase CLI
- Google Maps API Key

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/SkillBridge.git
   cd SkillBridge/skillbridge
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Run `flutterfire configure` to set up your project.
   - Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are correctly placed.

4. **Run Code Generation:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Launch the app:**
   ```bash
   flutter run
   ```

---
*Built with ❤️ by the SkillBridge Team.*
