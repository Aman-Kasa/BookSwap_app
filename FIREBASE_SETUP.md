# Firebase Setup Guide

## Step 1: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Create a project"
3. Enter project name: "bookswap-app"
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication
1. In Firebase console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Save changes

## Step 3: Create Firestore Database
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode"
4. Select location closest to your users
5. Click "Done"

## Step 4: Enable Storage
1. Go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode"
4. Select same location as Firestore
5. Click "Done"

## Step 5: Configure Flutter App
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. Login to Firebase: `firebase login`
4. In your Flutter project root, run: `flutterfire configure`
5. Select your Firebase project
6. Select platforms (Android, iOS)
7. This will generate `firebase_options.dart`

## Step 6: Android Configuration
1. Download `google-services.json` from Firebase console
2. Place it in `android/app/` directory
3. Add to `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```
4. Add to `android/build.gradle`:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```

## Step 7: iOS Configuration (if needed)
1. Download `GoogleService-Info.plist` from Firebase console
2. Add it to `ios/Runner/` in Xcode
3. Ensure it's added to the target

## Step 8: Test Connection
1. Run `flutter run`
2. Try creating an account
3. Check Firebase console to see if user was created
4. Test book creation and check Firestore

## Firestore Security Rules
Replace the default rules with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.ownerId == request.auth.uid);
    }
    
    match /chatRooms/{chatRoomId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chatRooms/$(chatRoomId)).data.participants;
      }
    }
  }
}
```

## Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```