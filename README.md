# Smart Roll Call - Attendance Management System

A comprehensive attendance management system that combines Flutter mobile application with ESP32-based automatic attendance tracking using MAC address detection. The system provides both manual attendance marking and automatic attendance recording when students connect to the ESP32 WiFi hotspot.

## 🚀 Features

### Flutter Mobile Application
- **Authentication System**: Secure login and user management
- **Batch Management**: Create and manage different batches/classes
- **Manual Attendance**: Mark attendance manually with an intuitive interface
- **Student Management**: Add, edit, and manage student records
- **Attendance Dashboard**: Visual charts and statistics
- **Attendance History**: View and export attendance records
- **Excel Export**: Export attendance data to Excel files
- **Real-time Sync**: All data synchronized with Firebase in real-time

### ESP32 Automatic Attendance (Planned Integration)
- **MAC Address Detection**: Automatically detect student devices when they connect to ESP32 WiFi
- **Automatic Attendance Marking**: Mark attendance automatically based on device MAC addresses
- **Facial Recognition Verification**: Students must capture live photo for verification when MAC-based attendance is detected
- **Anti-Proxy System**: Prevents proxy attendance by requiring physical presence verification through facial recognition
- **Firebase Integration**: Direct integration with Firebase database (replacing IFTTT and Google Sheets)
- **Device Registration**: Students register their device MAC addresses in the app
- **Dual Tracking**: Support both manual and automatic attendance methods

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Flutter App    │    │   Firebase      │    │   ESP32 Module  │
│  (Manual Mode)  │◄──►│   Database      │◄──►│ (Auto Mode)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Current Implementation
- **Flutter App** ↔ **Firebase Database**: Manual attendance management
- **ESP32 Module**: Standalone WiFi hotspot with MAC address detection (currently sends data to IFTTT/Google Sheets)

### Planned Integration
- **ESP32 Module** → **Firebase Database**: Direct attendance marking
- **Student Device Registration**: MAC addresses stored in Firebase
- **Unified Attendance Records**: Both manual and automatic attendance in single database

## 📱 Flutter App Structure

```
lib/
├── auth/                    # Authentication related screens
│   ├── auth_page.dart      # Main authentication wrapper
│   ├── login_page.dart     # Login interface
│   └── home_page.dart      # Post-login home
├── models/
│   └── student.dart        # Student data model
├── screens/
│   ├── AttendanceScreen.dart         # Manual attendance marking
│   ├── attendance_dashboard.dart     # Analytics and charts
│   ├── homescreen.dart              # Main dashboard
│   └── View-Edit History/           # Attendance history features
├── services/
│   ├── auth_service.dart           # Firebase authentication
│   └── firestore_service.dart      # Database operations
└── widgets/
    ├── AddStudentModal.dart        # Student addition interface
    └── batches.dart               # Batch management widgets
```

## 🔧 ESP32 Module

### Hardware Requirements
- ESP32 Development Board
- WiFi capability
- Built-in LED (for status indication)

### Current Functionality
- Creates WiFi hotspot with configurable SSID and password
- Detects connected devices and captures MAC addresses
- Maintains list of registered student MAC addresses
- LED indication for internet connectivity status
- Sends attendance data to IFTTT webhook (to be replaced with Firebase)

### Planned Enhancements
- Direct Firebase database integration
- Real-time attendance synchronization
- Device registration management
- Conflict resolution between manual and automatic attendance

## 🛠️ Technology Stack

### Flutter Application
- **Framework**: Flutter 3.5.3+
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **State Management**: Provider/setState
- **Charts**: Syncfusion Flutter Charts
- **Export**: Excel package
- **Camera**: Camera plugin for live photo capture
- **Facial Recognition**: ML Kit Face Detection or custom ML model
- **Platform**: Cross-platform (Android, iOS, Web)

### ESP32 Module
- **Platform**: Arduino IDE
- **Microcontroller**: ESP32
- **Networking**: WiFi (AP + STA mode)
- **Data Format**: JSON
- **Communication**: HTTP/HTTPS
- **Libraries**: WiFi, ArduinoJson, HTTPClient

### Backend Services
- **Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **Storage**: Firebase Storage (for exports)
- **Real-time Updates**: Firestore real-time listeners

## 📋 Installation & Setup

### Prerequisites
- Flutter SDK (≥3.5.3)
- Android Studio / VS Code
- Firebase account
- Arduino IDE (for ESP32)
- ESP32 development board

### Flutter App Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/YourUsername/Smart_RollCall_Flutter.git
   cd Smart_RollCall_Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a new Firebase project
   - Enable Firestore Database and Authentication
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place configuration files in respective platform directories
   - Update `firebase_options.dart` with your project configuration

4. **Run the application**
   ```bash
   flutter run
   ```

### ESP32 Setup

1. **Install Arduino IDE**
   - Download and install Arduino IDE
   - Install ESP32 board package

2. **Install Required Libraries**
   ```
   - WiFi (built-in)
   - ArduinoJson
   - HTTPClient (built-in)
   ```

3. **Configure ESP32 Code**
   - Open `Arduino Code ESP32 Module/Area51_CN_Project.ino`
   - Update WiFi credentials and settings
   - Add student MAC addresses and details
   - Configure Firebase endpoint (when implementing direct integration)

4. **Upload to ESP32**
   - Connect ESP32 to computer
   - Select correct board and port
   - Upload the code

## 📊 Database Schema

### Students Collection
```json
{
  "id": "auto-generated",
  "name": "Student Name",
  "enrollNumber": "enrollment_id",
  "macAddress": "AA:BB:CC:DD:EE:FF",  // For ESP32 integration
  "profileImageUrl": "firebase_storage_url",  // For facial recognition
  "isPresent": false,
  "createdAt": "timestamp"
}
```

### Batches Collection
```json
{
  "batchId": "auto-generated",
  "batchName": "Class Name",
  "batchYear": "2024",
  "title": "Batch Title",
  "icon": "icon_code_point",
  "createdAt": "timestamp"
}
```

### Attendance Records
```json
{
  "attendanceId": "auto-generated",
  "batchId": "batch_reference",
  "date": "YYYY-MM-DD",
  "records": [
    {
      "studentId": "student_reference",
      "isPresent": true,
      "markedAt": "timestamp",
      "method": "manual|automatic",  // New field for tracking method
      "deviceMac": "AA:BB:CC:DD:EE:FF",  // For automatic attendance
      "verificationImageUrl": "firebase_storage_url",  // Live captured image for verification
      "facialVerificationStatus": "verified|failed|pending"  // Facial recognition result
    }
  ]
}
```

## 🔄 Integration Roadmap

### Phase 1: Current State ✅
- Flutter app with manual attendance
- ESP32 with IFTTT integration
- Separate systems working independently

### Phase 2: Database Integration 🚧
- Replace IFTTT with direct Firebase calls from ESP32
- Add MAC address field to student records
- Implement device registration in Flutter app

### Phase 3: Unified System with Facial Recognition 📋
- Real-time sync between manual and automatic attendance
- Facial recognition integration for anti-proxy verification
- Live photo capture when MAC-based attendance is detected
- Profile image storage and comparison system
- Conflict resolution (if both methods mark attendance)
- Enhanced reporting with attendance method tracking

### Phase 4: Advanced Features 🚀
- Facial recognition for anti-proxy attendance verification
- Multiple ESP32 modules for different locations
- Geofencing for attendance validation
- Advanced analytics and reporting
- Mobile app notifications for automatic attendance

## 📈 Usage

### Manual Attendance
1. Login to the Flutter app
2. Select or create a batch
3. Add students to the batch
4. Use the attendance screen to mark present/absent
5. Save attendance record
6. View reports and export data

### Automatic Attendance with Facial Verification (After Integration)
1. Register student devices (MAC addresses) and profile photos in the app
2. Deploy ESP32 in classroom/location
3. Students connect to ESP32 WiFi hotspot
4. System detects MAC address and prompts student for live photo capture
5. Student captures live photo through mobile app
6. Facial recognition compares live photo with stored profile image
7. Attendance marked only if facial verification succeeds
8. Real-time updates reflected in Flutter app with verification status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](Smart-Roll-Call-app-main/LICENSE.md) file for details.

## 🙋‍♂️ Support

For support and questions:
- Create an issue in the GitHub repository
- Check existing documentation
- Review the troubleshooting section

## 🔧 Troubleshooting

### Common Flutter Issues
- **Build errors**: Run `flutter clean` and `flutter pub get`
- **Firebase connection**: Verify configuration files and project settings
- **Permission errors**: Check platform-specific permissions in manifests

### ESP32 Issues
- **Upload failures**: Check board selection and USB connection
- **WiFi connection**: Verify credentials and network availability
- **Memory issues**: Optimize code and reduce memory usage

## 🚀 Future Enhancements

- Machine learning for attendance pattern analysis
- Advanced facial recognition with liveness detection
- Behavioral biometrics for enhanced security
- Mobile app for teachers and students
- Integration with LMS systems
- Voice recognition as additional verification layer
- Multi-language support
- Anti-spoofing measures for photo verification
