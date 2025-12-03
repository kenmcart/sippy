# Quick Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Add project" or "Create a project"
3. Enter project name (e.g., "sippy-app")
4. Continue through the setup (you can disable Google Analytics if you want)
5. Click "Create project"

## Step 2: Enable Email/Password Authentication

1. In your Firebase project, click **Authentication** in the left sidebar
2. Click **Get Started**
3. Go to the **Sign-in method** tab
4. Click on **Email/Password**
5. Enable the first toggle (Email/Password)
6. Click **Save**

## Step 3: Add Web App to Firebase

1. In Firebase Console, click the **Web icon** (`</>`) or go to Project Settings
2. Register your app with a nickname (e.g., "Sippy Web")
3. **Copy the Firebase configuration object** - it looks like this:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

## Step 4: Configure Flutter App

### Option A: Using FlutterFire CLI (Interactive)

Run this in your terminal:
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
cd /Users/prachimahapatra/Desktop/sippy-2
flutterfire configure
```

Then:
- Select your Firebase project
- Choose platforms: **web** (and iOS/Android if needed)
- It will generate `lib/firebase_options.dart` automatically

### Option B: Manual Web Configuration

1. Create `lib/firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );
}
```

2. Replace the placeholder values with your actual Firebase config values.

3. Update `lib/main.dart` to use the options:

```dart
import 'firebase_options.dart';

// In main() function, replace:
await Firebase.initializeApp();
// With:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Step 5: Test

1. Restart your Flutter app:
   ```bash
   flutter run -d chrome --web-port=8080
   ```

2. Go to http://localhost:8080
3. You should see the login screen
4. Click "Sign Up" to create a test account
5. Check Firebase Console → Authentication → Users to see your new user

## Troubleshooting

- **"Firebase not configured" warning**: Make sure you've completed Step 4
- **Can't sign up**: Make sure Email/Password is enabled in Firebase Console
- **Build errors**: Run `flutter pub get` after adding firebase_options.dart

