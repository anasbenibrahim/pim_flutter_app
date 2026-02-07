# PIM Flutter App

A Flutter mobile application for Personal Information Management (PIM) with user authentication and role-based features.

## Features

- **User Authentication**: Login and registration for three user roles
- **Role-Based Registration**: Separate registration flows for Patient, Volontaire, and Family Member
- **OTP Verification**: Email-based OTP verification for registration
- **Password Reset**: Forgot password flow with OTP verification
- **Image Upload**: Profile picture upload during registration
- **Dark/Light Theme**: Support for both themes with purple accent color
- **BLoC State Management**: Clean architecture with BLoC pattern
- **GetX Integration**: Using GetX for snackbars and utilities
- **Secure Storage**: Token storage using SharedPreferences
- **Profile Management**: Update profile with role-specific fields
- **Bottom Navigation**: Home and Profile tabs with smooth transitions

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
│   │   └── pages/      # Auth pages (login, register, OTP)
│   ├── home/           # Home feature
│   │   └── pages/      # Home page
│   ├── navigation/     # Navigation feature
│   │   └── pages/      # Main navigation with bottom bar
│   └── profile/        # Profile feature
│       └── pages/      # Profile and update profile pages
└── main.dart           # App entry point
```

## User Flows

### 1. Get Started
- Initial screen with options to Login or Register

### 2. Login Flow
- Email and password input
- Validation and authentication
- Navigate to Main Navigation on success

### 3. Registration Flow
- Role selection (Patient, Volontaire, Family Member)
- Role-specific registration forms
- Image upload (optional)
- OTP verification via email
- Navigate to Main Navigation on success

### 4. Password Reset Flow
- Forgot password page (email input)
- OTP verification page
- Reset password page (new password and confirmation)

### 5. Main Navigation
- Bottom navigation bar with Home and Profile tabs
- Smooth page transitions
- Profile tab shows user's profile image

### 6. Profile
- Display user information
- Menu items: Manage Profile, Customize My Level, Manage Notification, FAQ, Settings, Log Out
- For patients: Display referral code with copy functionality

### 7. Update Profile
- Role-specific editable fields
- Profile image update
- For patients: Date of birth, sobriety date, and addiction type are not updatable (preserved from registration)

## User Roles

### Patient Registration
- Email, password
- Nom, prenom, age
- Date of birth
- Sobriety date
- Addiction type (Opiates, Cocaine, Alcohol, Other)
- Profile image (optional)
- OTP verification required
- Referral code generated automatically

### Volontaire Registration
- Email, password
- Nom, prenom, age
- Profile image (optional)
- OTP verification required

### Family Member Registration
- Email, password
- Nom, prenom
- Referral key (required - links to patient)
- Profile image (optional)
- OTP verification required

## Theme Configuration

The app uses a purple color scheme (`#593A84`) with support for both light and dark themes. Theme configuration is in `lib/core/theme/app_colors.dart`.

## State Management

The app uses the BLoC (Business Logic Component) pattern for state management:
- `AuthBloc`: Handles authentication state and events
- Events: Login, Register (for each role), Logout, CheckAuth, OTP Verification, Profile Updates
- States: Initial, Loading, Authenticated, Unauthenticated, Error, OtpSent, RegistrationOtpSent, OtpVerified, PasswordResetSuccess

## API Integration

The app communicates with the backend through `ApiService`:
- Token management (access and refresh tokens)
- Automatic token refresh
- Error handling
- Multipart file upload support
- OTP verification endpoints

## Dependencies

- `flutter_bloc`: State management
- `get`: GetX for snackbars and utilities
- `http`: HTTP client
- `shared_preferences`: Local storage
- `image_picker`: Image selection
- `intl`: Date formatting
- `equatable`: Value equality
- `pinput`: PIN input for OTP verification
- `google_nav_bar`: Bottom navigation bar
- `flutter_screenutil`: Responsive design

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

4. **OTP Not Received**:
   - Check email spam folder
   - Verify email configuration in backend `.env` file
   - Check backend logs for email sending errors

## Development Notes

- The app follows clean architecture principles
- Reusable widgets are separated into `core/widgets`
- Colors and themes are centralized for easy maintenance
- BLoC pattern ensures separation of concerns
- Error handling is implemented at both BLoC and UI levels
- GetX is used for snackbars (positioned at top)
- All snackbars use Get.snackbar for consistency

## Recent Updates

- Added OTP verification for registration flow
- Integrated GetX for snackbar management
- Added profile and update profile pages
- Implemented bottom navigation with smooth transitions
- Added referral code display for patients
- Fixed deprecated API usage (withOpacity -> withValues)
