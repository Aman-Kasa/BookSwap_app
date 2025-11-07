import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _user = await _authService.getCurrentUserData();
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String name, String university) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _authService.signUp(email, password, name, university);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _authService.signIn(email, password);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    bool isVerified = await _authService.checkEmailVerified();
    if (isVerified) {
      _user = await _authService.getCurrentUserData();
      notifyListeners();
    }
    return isVerified;
  }

  Future<void> getCurrentUserData() async {
    _user = await _authService.getCurrentUserData();
    notifyListeners();
  }
}