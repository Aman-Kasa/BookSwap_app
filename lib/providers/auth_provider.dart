/// Authentication Provider for BookSwap Application
/// 
/// Manages user authentication state using Firebase Auth and provides
/// reactive updates to the UI through ChangeNotifier pattern.
/// 
/// Features:
/// - User sign up with email verification
/// - User sign in with email/password
/// - Real-time authentication state changes
/// - Loading state management
/// - Email verification handling

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider class that manages authentication state for the entire app
/// 
/// Uses Firebase Authentication for user management and provides
/// reactive state updates to listening widgets
class AuthProvider with ChangeNotifier {
  // Private instance of AuthService for Firebase operations
  final AuthService _authService = AuthService();
  
  // Current user data model
  UserModel? _user;
  
  // Loading state for UI feedback
  bool _isLoading = false;

  // Getters for accessing private state
  /// Returns current user data or null if not authenticated
  UserModel? get user => _user;
  
  /// Returns true if any authentication operation is in progress
  bool get isLoading => _isLoading;
  
  /// Returns true if user is currently authenticated
  bool get isAuthenticated => _user != null;

  /// Constructor that sets up authentication state listener
  /// 
  /// Listens to Firebase Auth state changes and updates the user data
  /// accordingly, notifying all listening widgets of changes
  AuthProvider() {
    // Listen to Firebase Auth state changes (login/logout)
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // User is signed in - fetch user data from Firestore
        _user = await _authService.getCurrentUserData();
      } else {
        // User is signed out - clear user data
        _user = null;
      }
      // Notify all listening widgets of the state change
      notifyListeners();
    });
  }

  /// Creates a new user account with email verification
  /// 
  /// [email] - User's email address (must be valid university email)
  /// [password] - User's password (minimum 6 characters)
  /// [name] - User's full name
  /// [university] - User's university name
  /// 
  /// Throws [FirebaseAuthException] if signup fails
  Future<void> signUp(String email, String password, String name, String university) async {
    // Set loading state for UI feedback
    _isLoading = true;
    notifyListeners();
    
    try {
      // Attempt to create new user account
      _user = await _authService.signUp(email, password, name, university);
      notifyListeners();
    } catch (e) {
      // Reset loading state on error
      _isLoading = false;
      notifyListeners();
      // Re-throw error for UI to handle
      throw e;
    }
    
    // Reset loading state on success
    _isLoading = false;
    notifyListeners();
  }

  /// Signs in existing user with email and password
  /// 
  /// [email] - User's registered email address
  /// [password] - User's password
  /// 
  /// Throws [FirebaseAuthException] if signin fails or email not verified
  Future<void> signIn(String email, String password) async {
    // Set loading state for UI feedback
    _isLoading = true;
    notifyListeners();
    
    try {
      // Attempt to sign in user
      _user = await _authService.signIn(email, password);
      notifyListeners();
    } catch (e) {
      // Reset loading state on error
      _isLoading = false;
      notifyListeners();
      // Re-throw error for UI to handle
      throw e;
    }
    
    // Reset loading state on success
    _isLoading = false;
    notifyListeners();
  }

  /// Signs out the current user
  /// 
  /// Clears user data and notifies listeners of the state change
  Future<void> signOut() async {
    // Sign out from Firebase Auth
    await _authService.signOut();
    
    // Clear local user data
    _user = null;
    
    // Notify listeners that user is signed out
    notifyListeners();
  }

  /// Sends email verification to the current user
  /// 
  /// Must be called after successful signup but before signin
  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  /// Checks if the current user's email is verified
  /// 
  /// Returns [true] if email is verified, [false] otherwise
  /// Updates user data if verification status has changed
  Future<bool> checkEmailVerified() async {
    // Check verification status with Firebase
    bool isVerified = await _authService.checkEmailVerified();
    
    if (isVerified) {
      // Email is now verified - update user data
      _user = await _authService.getCurrentUserData();
      notifyListeners();
    }
    
    return isVerified;
  }

  /// Refreshes current user data from Firestore
  /// 
  /// Useful for updating user information after profile changes
  Future<void> getCurrentUserData() async {
    _user = await _authService.getCurrentUserData();
    notifyListeners();
  }
}