# Qeyafa Mobile App (Flutter)

## Overview
This is the Flutter mobile application for Qeyafa - an AI tailoring app for customers and designers.

## Project Structure
```
mobile-app/
├── lib/
│   ├── models/              # Data models
│   │   ├── user.dart        # User model with role support
│   │   ├── design.dart      # Design model
│   │   └── category.dart    # Category model
│   ├── services/            # API service classes
│   │   ├── api_service.dart      # Base API service
│   │   ├── auth_service.dart     # Authentication service
│   │   ├── design_service.dart   # Design CRUD operations
│   │   ├── category_service.dart # Category operations
│   │   └── user_service.dart     # User profile operations
│   ├── providers/           # State management (Riverpod)
│   │   └── auth_provider.dart    # Auth state management
│   ├── screens/             # App screens
│   │   ├── auth/            # Authentication screens
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── home_screen.dart
│   │   ├── designs/         # Design browsing screens
│   │   │   └── designs_list_screen.dart
│   │   ├── profile/         # User profile screens
│   │   │   └── profile_screen.dart
│   │   └── admin/           # Admin screens (future)
│   ├── widgets/             # Reusable UI components
│   │   └── design_card.dart # Design grid item widget
│   ├── utils/               # Constants and helpers
│   │   ├── constants.dart   # App-wide constants
│   │   ├── helpers.dart     # Utility functions
│   │   └── app_config.dart  # Environment configuration
│   └── main.dart            # App entry point
├── assets/
│   ├── images/              # Image assets
│   └── icons/               # Icon assets
└── pubspec.yaml             # Flutter dependencies
```

## Dependencies
- **http** (^1.1.0): HTTP client for API calls
- **provider** (^6.1.1): State management (alternative)
- **flutter_riverpod** (^2.4.9): State management (Riverpod)
- **shared_preferences** (^2.2.2): Local storage for preferences
- **cached_network_image** (^3.3.0): Image caching for designs
- **flutter_secure_storage** (^9.0.0): Secure token storage
- **dartz** (^0.10.1): Functional programming utilities
- **intl** (^0.18.1): Internationalization and formatting

## Setup Instructions

### Prerequisites
- Flutter SDK (>=2.19.0 <3.0.0)
- Android Studio / Xcode (for emulators)
- Backend API running on http://localhost:8000

### Installation
1. Install dependencies:
```bash
cd mobile-app
flutter pub get
```

2. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device_id>
```

## API Configuration
The app connects to the FastAPI backend. Update the base URL in:
- `lib/services/api_service.dart`
- `lib/utils/app_config.dart`

Default configurations:
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_MACHINE_IP:8000`

## Authentication Flow
1. App starts with splash screen
2. Checks for stored JWT token
3. If authenticated, navigates to home screen
4. If not authenticated, shows login screen
5. JWT token stored securely using flutter_secure_storage

## Features Implemented
✅ User authentication (login/register)
✅ JWT token management
✅ User profile screen
✅ Design listing screen
✅ Role-based user model (customer, designer, admin, tailor)
✅ Secure token storage
✅ API service layer
✅ State management with Riverpod

## Next Steps
- [ ] Implement design detail screen
- [ ] Add design creation/editing (for designers)
- [ ] Implement admin dashboard
- [ ] Add measurement capture feature
- [ ] Implement order management
- [ ] Add payment integration
- [ ] Implement push notifications
- [ ] Add image upload functionality

## Testing
```bash
flutter test
```

## Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Troubleshooting
- **Connection refused**: Make sure backend is running on port 8000
- **Token expired**: Implement token refresh mechanism
- **CORS errors**: Configure CORS in FastAPI backend
