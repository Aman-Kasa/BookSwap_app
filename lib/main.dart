/// BookSwap - Student Textbook Exchange Platform
/// 
/// A Flutter mobile application that enables students to exchange textbooks
/// through a marketplace system with real-time chat functionality.
/// 
/// Features:
/// - Firebase Authentication with email verification
/// - Real-time book listings with CRUD operations
/// - Swap offer system with state management
/// - Real-time chat between users
/// - Cross-platform support (Android, iOS, Web)
/// 
/// Author: Aman Kasa
/// University: African Leadership University
/// Date: November 2025

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Firebase configuration
import 'firebase_options.dart';

// State management providers
import 'providers/auth_provider.dart' as app_auth;
import 'providers/book_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/swap_provider.dart';

// Screen imports
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'widgets/shared_layout.dart';

// Theme and styling
import 'utils/app_theme.dart';

/// Main entry point of the BookSwap application
/// 
/// Initializes Firebase and sets up the app with all necessary providers
void main() async {
  // Ensure Flutter binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Start the application
  runApp(MyApp());
}

/// Root widget of the BookSwap application
/// 
/// Sets up the MultiProvider for state management and configures
/// the MaterialApp with theme and initial route
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Configure all state management providers
      providers: [
        // Authentication state management
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        
        // Book listings and CRUD operations
        ChangeNotifierProvider(create: (_) => BookProvider()),
        
        // Real-time chat functionality
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        
        // Swap offers and state tracking
        ChangeNotifierProvider(create: (_) => SwapProvider()),
      ],
      child: MaterialApp(
        title: 'BookSwap',
        theme: AppTheme.theme, // Custom dark theme with yellow accents
        home: SplashScreen(), // Initial splash screen
        debugShowCheckedModeBanner: false, // Hide debug banner
      ),
    );
  }
}

/// Authentication wrapper that determines which screen to show
/// based on user authentication and email verification status
/// 
/// Flow:
/// 1. Not authenticated -> LoginScreen
/// 2. Authenticated but email not verified -> EmailVerificationScreen
/// 3. Authenticated and email verified -> SharedLayout (main app)
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is authenticated
        if (authProvider.isAuthenticated) {
          // Get current Firebase user to check email verification
          User? firebaseUser = FirebaseAuth.instance.currentUser;
          
          // Verify email is confirmed before allowing app access
          if (firebaseUser != null && firebaseUser.emailVerified) {
            // User is authenticated and verified - show main app
            return SharedLayout();
          } else {
            // User is authenticated but email not verified
            return EmailVerificationScreen();
          }
        } else {
          // User is not authenticated - show login screen
          return LoginScreen();
        }
      },
    );
  }
}
