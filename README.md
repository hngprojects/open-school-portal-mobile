//Duso
# SchoolBase

A comprehensive school management application built with Flutter that enables efficient attendance tracking, NFC card management, and role-based access control for admins, teachers, and gatemen.

## Features

### 🔐 Authentication
- Email/password-based login system
- Role-based access control (Admin, Teacher, Gateman)
- Secure token management using SharedPreferences
- Session persistence

### 📱 Admin Features
- **NFC Tag Management**: Register and manage NFC cards for students
- **User Search**: Search and assign NFC cards to users
- **Attendance Records**: View and manage all attendance logs
- **System Administration**: Central control panel for school operations

### 👨‍🏫 Teacher Features
- **Class Management**: View assigned classes
- **Attendance Marking**: Take attendance via NFC scanning or manual entry
- **Gate History**: Monitor student entry/exit logs
- **Offline Sync**: Sync offline attendance records when connectivity is restored

### 🚪 Gateman Features
- **NFC Scanner**: Real-time NFC card scanning for check-in/check-out
- **Attendance Logging**: Automatic attendance recording
- **Offline Support**: Store scan records locally when offline
- **Scan History**: View all scanned records with timestamps

## Tech Stack

- **Frontend**: Flutter
- **State Management**: StatefulWidget
- **Local Storage**: SQLite (via `DatabaseHelper`)
- **Preferences**: SharedPreferences
- **NFC Integration**: NFC plugin
- **HTTP Client**: Dart HTTP package
- **Platforms**: Android, iOS, Web, Windows, Linux

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/
│   ├── login_screen.dart       # Authentication
│   ├── main_nav_screen.dart    # Navigation hub
│   ├── admin_dashboard.dart    # Admin panel
│   ├── admin_history_screen.dart
│   ├── teacher_dashboard.dart  # Teacher class list
│   ├── teacher_gate_history.dart
│   ├── gateman_screen.dart     # NFC scanner
│   ├── gateman_history_screen.dart
│   ├── profile_screen.dart     # User profile
│   └── manual_attendance_screen.dart
├── services/
│   ├── auth_service.dart       # Authentication logic
│   ├── attendance_service.dart # Attendance tracking
│   ├── nfc_service.dart        # NFC operations
│   ├── admin_service.dart      # Admin operations
│   └── database_helper.dart    # SQLite management
├── widgets/
│   ├── logout_dialog.dart      # Logout confirmation
│   ├── attendance_toggle.dart  # Check-in/out toggle
│   └── nfc_visual.dart         # NFC ripple animation
└── utils/
    └── constants.dart          # App colors and constants
```

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- NFC-enabled device for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd school_base
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint**
   - Edit `lib/services/auth_service.dart`
   - Update `baseUrl` to your backend API

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Hardcoded Test Credentials
For development testing, gateman login is hardcoded:
- **Email**: `gate@school.com`
- **Password**: `gateman1`

Update in `lib/services/auth_service.dart` as needed.

### API Configuration
- **Base URL**: `https://api.staging.borjigin.emerj.net`
- Modify in `lib/services/auth_service.dart`

## Key Features Explained

### NFC Integration
The app uses NFC technology to:
- Register student cards (Admin)
- Mark attendance via card scanning (Gateman, Teacher)
- Track entry/exit points

### Offline Support
- Local SQLite database stores attendance records
- Automatic sync when connectivity is restored
- User-initiated sync from profile screen

### Role-Based Navigation
Different screens are displayed based on user role:
- **Admin**: Admin Dashboard + Profile
- **Gateman**: Scanner + History
- **Teacher**: Class List + Gate History

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login

### Attendance
- `POST /api/v1/attendance/mark` - Record attendance
- `GET /api/v1/attendance/history` - Fetch attendance records

### Admin
- `POST /api/v1/nfc/register` - Register NFC card
- `GET /api/v1/users` - Search users
- `GET /api/v1/attendance/all` - All attendance logs

## Testing

Run the test suite:
```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Troubleshooting

### NFC Not Detected
- Ensure device has NFC capability
- Enable NFC in device settings
- Check `android/app/src/main/AndroidManifest.xml` permissions

### Login Fails
- Verify API endpoint is accessible
- Check network connectivity
- Review `auth_service.dart` for API configuration

### Attendance Sync Issues
- Check local database for offline records
- Ensure internet connection for sync
- Review `attendance_service.dart` logs

## Contributing

1. Create a feature branch
2. Commit your changes
3. Push to the repository
4. Submit a pull request

**Version**: 1.0.0  
