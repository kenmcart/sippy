# Firebase Authentication Setup

This app uses Firebase Authentication for user login and signup. Follow these steps to set up Firebase:

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard

## Step 2: Enable Email/Password Authentication

1. In your Firebase project, go to **Authentication** in the left sidebar
2. Click **Get Started**
3. Go to the **Sign-in method** tab
4. Click on **Email/Password**
5. Enable the first toggle (Email/Password)
6. Click **Save**

## Step 3: Configure Flutter App with Firebase

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```
   
   This will:
   - Detect your Firebase projects
   - Let you select which platforms to configure (web, iOS, Android)
   - Generate `lib/firebase_options.dart` automatically

3. Update `lib/main.dart` to use the generated options:
   ```dart
   import 'firebase_options.dart';
   
   // In main() function:
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

### Option B: Manual Configuration (Web only for quick testing)

For web, you can add Firebase config directly in `web/index.html`:

```html
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js"></script>
<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

Get these values from: Firebase Console → Project Settings → General → Your apps

## Step 4: Test the App

1. Run the app:
   ```bash
   flutter run -d chrome
   ```

2. You should see the login screen
3. Click "Sign Up" to create a new account
4. After signing up, you'll be automatically logged in

## Troubleshooting

- **"Firebase initialization error"**: Make sure you've completed Step 3 and configured Firebase properly
- **"Email already in use"**: The email is already registered. Try signing in instead.
- **"Weak password"**: Use a password with at least 6 characters

## Notes

- The app will show the login screen if the user is not authenticated
- User data (favorites, settings) is stored locally and will persist after logout
- For production, consider adding additional security rules and features

