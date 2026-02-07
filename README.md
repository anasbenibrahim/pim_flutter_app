# PIM Flutter App

A Flutter mobile application for Personal Information Management (PIM) with user authentication and role-based features.

## Features

- **User Authentication**: Login and registration for three user roles
- **Role-Based Registration**: Separate registration flows for Patient, Volontaire, and Family Member
- **Image Upload**: Profile picture upload during registration
- **Dark/Light Theme**: Support for both themes with purple accent color
- **BLoC State Management**: Clean architecture with BLoC pattern
- **Secure Storage**: Token storage using SharedPreferences

## Prerequisites

- Flutter SDK 3.10.3 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Backend API running on `http://localhost:8080`

## Setup Instructions

### 1. Install Dependencies

```bash
cd Flutter/pimapp
flutter pub get
```

### 2. Configure API Endpoint

The app automatically detects the platform and uses the appropriate base URL:
- **Android Emulator**: Automatically uses `http://10.0.2.2:8080/api` (maps to host machine's localhost)
- **iOS Simulator**: Automatically uses `http://localhost:8080/api`
- **Physical Devices**: You need to manually configure your computer's IP address

#### For Physical Devices:

1. Find your computer's IP address:
   - **macOS/Linux**: Run `ifconfig` or `ip addr` in terminal
   - **Windows**: Run `ipconfig` in command prompt
   - Look for your local network IP (usually starts with `192.168.x.x` or `10.x.x.x`)

2. Update `lib/core/constants/api_constants.dart`:
   ```dart
   static String get baseUrl {
     const String? envUrl = String.fromEnvironment('API_BASE_URL');
     if (envUrl != null && envUrl.isNotEmpty) {
       return envUrl;
     }
     
     if (Platform.isAndroid) {
       return 'http://YOUR_COMPUTER_IP:8080/api'; // Replace YOUR_COMPUTER_IP
     } else if (Platform.isIOS) {
       return 'http://YOUR_COMPUTER_IP:8080/api'; // Replace YOUR_COMPUTER_IP
     }
     return 'http://localhost:8080/api';
   }
   ```

3. **Alternative**: Use environment variable when running:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080/api
   ```

**Important**: 
- Ensure your backend server is running on port 8080
- Ensure your computer's firewall allows connections on port 8080
- Physical device and computer must be on the same Wi-Fi network

### 3. Run the Application

```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/      # API constants and configuration
│   ├── models/         # Data models
│   ├── services/       # API service layer
│   ├── theme/          # App colors and themes
│   └── widgets/        # Reusable widgets
├── features/
│   ├── auth/           # Authentication feature
│   │   ├── bloc/       # BLoC for authentication
│   │   └── pages/      # Auth pages (login, register)
│   └── home/           # Home feature
│       └── pages/      # Home page
└── main.dart           # App entry point
```

## User Flows

### 1. Get Started
- Initial screen with options to Login or Register

### 2. Login Flow
- Email and password input
- Validation and authentication
- Navigate to Home on success

### 3. Registration Flow
- Role selection (Patient, Volontaire, Family Member)
- Role-specific registration forms
- Image upload (optional)
- Navigate to Home on success

### 4. Home
- Display user information
- Show user role
- Logout functionality

## User Roles

### Patient Registration
- Email, password
- Nom, prenom, age
- Date of birth
- Sobriety date
- Addiction type (Opiates, Cocaine, Alcohol, Other)
- Profile image (optional)

### Volontaire Registration
- Email, password
- Nom, prenom, age
- Profile image (optional)

### Family Member Registration
- Email, password
- Nom, prenom
- Referral key (required - links to patient)
- Profile image (optional)

## Theme Configuration

The app uses a purple color scheme (`#593A84`) with support for both light and dark themes. Theme configuration is in `lib/core/theme/app_colors.dart`.

## State Management

The app uses the BLoC (Business Logic Component) pattern for state management:
- `AuthBloc`: Handles authentication state and events
- Events: Login, Register (for each role), Logout, CheckAuth
- States: Initial, Loading, Authenticated, Unauthenticated, Error

## API Integration

The app communicates with the backend through `ApiService`:
- Token management (access and refresh tokens)
- Automatic token refresh
- Error handling
- Multipart file upload support

## Dependencies

- `flutter_bloc`: State management
- `http`: HTTP client
- `shared_preferences`: Local storage
- `image_picker`: Image selection
- `intl`: Date formatting
- `equatable`: Value equality

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

1. **API Connection Error (Connection Refused)**: 
   - **Check if backend is running**: Ensure Spring Boot server is running on port 8080
   - **Android Emulator**: The app automatically uses `10.0.2.2:8080` - no configuration needed
   - **iOS Simulator**: The app automatically uses `localhost:8080` - no configuration needed
   - **Physical Device**: 
     - Update `api_constants.dart` with your computer's IP address
     - Ensure device and computer are on the same Wi-Fi network
     - Check firewall settings - port 8080 must be accessible
     - Verify backend is listening on `0.0.0.0:8080` (not just `localhost:8080`)
   - **Test backend**: Open `http://localhost:8080/api/auth/me` in browser to verify backend is accessible

2. **Image Upload Issues**:
   - Check file permissions
   - Verify image picker permissions are granted

3. **Build Errors**:
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter SDK version compatibility

## Development Notes

- The app follows clean architecture principles
- Reusable widgets are separated into `core/widgets`
- Colors and themes are centralized for easy maintenance
- BLoC pattern ensures separation of concerns
- Error handling is implemented at both BLoC and UI levels

## Future Enhancements

- Token refresh on app resume
- Offline support
- Push notifications
- Biometric authentication
- Profile editing
- Password reset functionality
