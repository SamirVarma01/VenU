# VenU 🎵

**Find concert buddies at your college**

VenU is a social networking app designed for college students to discover concerts, connect with fellow music lovers, and find friends to attend events together.

## Features

- 🎓 **College-verified accounts** - Sign up with your .edu email
- 🎤 **Concert discovery** - Browse upcoming shows at local venues
- 👥 **Social connections** - Connect with other students attending the same concerts
- 💬 **Messaging** - Chat with friends and plan your concert outings
- 🎫 **Event tracking** - Keep track of concerts you're attending

## Tech Stack

- **Platform**: iOS & macOS (SwiftUI)
- **Backend**: Firebase (Authentication, Firestore)
- **Data Persistence**: SwiftData
- **Language**: Swift 6

## Setup Instructions

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ / macOS 14.0+ deployment target
- Firebase account

### Firebase Configuration

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one

2. **Add iOS App to Firebase**
   - In Firebase Console, add an iOS app
   - Use your app's bundle identifier (e.g., `com.yourname.VenU`)
   - Download the `GoogleService-Info.plist` file

3. **Add Configuration File**
   - Place `GoogleService-Info.plist` in your Xcode project root
   - ⚠️ **DO NOT commit this file to Git** (it's already in .gitignore)

4. **Enable Authentication**
   - In Firebase Console, go to Authentication
   - Enable "Email/Password" sign-in method

5. **Set up Firestore Database**
   - In Firebase Console, go to Firestore Database
   - Create a database in production mode
   - Set up security rules (example below)

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Schools collection
    match /schools/{schoolId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can modify schools
    }
    
    // Concerts collection
    match /concerts/{concertId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Adjust based on your needs
    }
    
    // Venues collection
    match /venues/{venueId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can modify venues
    }
    
    // Concert Attendance
    match /concert_attendance/{attendanceId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && resource.data.userID == request.auth.uid;
    }
    
    // Friendships
    match /friendships/{friendshipId} {
      allow read: if request.auth != null && 
        (resource.data.user1ID == request.auth.uid || resource.data.user2ID == request.auth.uid);
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.user1ID == request.auth.uid || resource.data.user2ID == request.auth.uid);
    }
    
    // Messages
    match /messages/{messageId} {
      allow read: if request.auth != null && 
        (resource.data.senderID == request.auth.uid || resource.data.receiverID == request.auth.uid);
      allow create: if request.auth != null && request.resource.data.senderID == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.senderID == request.auth.uid;
    }
  }
}
```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SamirVarma01/VenU.git
   cd VenU
   ```

2. **Add your Firebase configuration**
   - Follow the Firebase Configuration steps above
   - Make sure `GoogleService-Info.plist` is in the project

3. **Open in Xcode**
   ```bash
   open VenU.xcodeproj
   # or if using workspace:
   open VenU.xcworkspace
   ```

4. **Install dependencies** (if using Swift Package Manager)
   - Xcode should automatically resolve packages
   - If not, go to File → Packages → Resolve Package Versions

5. **Build and Run**
   - Select your target device or simulator
   - Press Cmd+R to build and run

## Project Structure

```
VenU/
├── Models/              # SwiftData models
│   ├── User.swift
│   ├── School.swift
│   ├── Concert.swift
│   ├── Venue.swift
│   ├── ConcertAttendance.swift
│   ├── Friendship.swift
│   └── Message.swift
├── Views/               # SwiftUI views
│   ├── AuthenticationView.swift
│   └── ContentView.swift
├── ViewModels/          # View models
│   └── AuthenticationViewModel.swift
├── Services/            # Business logic & services
│   └── FirebaseManager.swift
├── Repositories/        # Data access layer
│   └── UserRepository.swift
└── VenUApp.swift       # App entry point
```

## Development

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI for all UI
- Prefer Swift Concurrency (async/await) over callbacks
- Use `@MainActor` for view models and UI-related code

### Testing

(Coming soon)

## Contributing

This is a personal project, but suggestions and feedback are welcome! Feel free to open an issue.

## Security Notes

⚠️ **Important**: Never commit the following files:
- `GoogleService-Info.plist`
- Any files containing API keys or secrets
- User data or credentials

These are already excluded in `.gitignore`.

## License

(Add your preferred license here)

## Author

Samir Varma

## Acknowledgments

- Firebase for backend services
- Apple for SwiftUI and SwiftData frameworks

---

**Note**: This app requires a college email address (.edu, .ac.uk, .ac.in) to sign up. Make sure to verify your email after registration.
