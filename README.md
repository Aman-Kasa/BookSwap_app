# BookSwap App

A Flutter mobile application for students to exchange textbooks through a marketplace system with real-time chat functionality.

## Features

- **Authentication**: Firebase Auth with email verification
- **Book Listings**: Full CRUD operations for book management
- **Swap System**: Real-time swap offers with status tracking
- **Chat System**: Real-time messaging between users
- **State Management**: Provider pattern for reactive UI
- **Clean Architecture**: Organized folder structure

## Architecture

```
lib/
├── models/          # Data models
├── services/        # Firebase services
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/           # Utility functions
```

## Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Create Firestore database
4. Enable Firebase Storage
5. Run `flutterfire configure` to generate firebase_options.dart
6. Replace the placeholder values in firebase_options.dart

## Database Schema

### Users Collection
```
users/{userId}
├── id: string
├── email: string
├── name: string
└── emailVerified: boolean
```

### Books Collection
```
books/{bookId}
├── id: string
├── title: string
├── author: string
├── condition: int (enum)
├── imageUrl: string
├── ownerId: string
├── ownerName: string
├── status: int (enum)
├── createdAt: timestamp
└── swapRequesterId: string?
```

### Chat Rooms Collection
```
chatRooms/{chatRoomId}
├── id: string
├── participants: string[]
├── lastMessage: string?
├── lastMessageTime: timestamp?
└── messages/{messageId}
    ├── id: string
    ├── senderId: string
    ├── receiverId: string
    ├── message: string
    └── timestamp: timestamp
```

## State Management

Using Provider pattern with three main providers:
- **AuthProvider**: Manages authentication state
- **BookProvider**: Handles book CRUD operations
- **ChatProvider**: Manages chat functionality

## Build Instructions

1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase (see Firebase Setup)
4. **IMPORTANT**: Copy `lib/firebase_options_template.dart` to `lib/firebase_options.dart` and replace placeholder values with your Firebase project keys
5. Run `flutter run` on a mobile device or emulator

## Security Note

⚠️ **NEVER commit `firebase_options.dart` to version control!** This file contains sensitive API keys and is already added to `.gitignore`.

## Dependencies

- firebase_core: ^3.6.0
- firebase_auth: ^5.3.1
- cloud_firestore: ^5.4.3
- firebase_storage: ^12.3.2
- provider: ^6.1.2
- image_picker: ^1.1.2
- cached_network_image: ^3.4.1
