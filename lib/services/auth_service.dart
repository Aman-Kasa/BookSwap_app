import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp(String email, String password, String name, String university) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        // Send email verification
        try {
          await user.sendEmailVerification();
          print('Verification email sent to: $email');
        } catch (e) {
          print('Error sending verification email during signup: $e');
          // Continue with signup even if email fails
        }
        
        UserModel userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
          emailVerified: false, // Properly enforce email verification
          university: university,
        );
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        // Check if email is verified
        await user.reload();
        User? reloadedUser = _auth.currentUser;
        
        if (reloadedUser != null && !reloadedUser.emailVerified) {
          await _auth.signOut();
          throw Exception('Please verify your email before signing in');
        }
        
        if (reloadedUser != null) {
          DocumentSnapshot doc = await _firestore.collection('users').doc(reloadedUser.uid).get();
          if (doc.exists) {
            // Update emailVerified status in Firestore
            await _firestore.collection('users').doc(reloadedUser.uid).update({
              'emailVerified': true,
            });
            
            Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
            userData['emailVerified'] = true;
            return UserModel.fromMap(userData);
          }
        }
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('AuthService: User signed out successfully');
    } catch (e) {
      print('AuthService: Error signing out: $e');
      throw e;
    }
  }

  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        print('Verification email sent to: ${user.email}');
      } catch (e) {
        print('Error sending verification email: $e');
        throw Exception('Failed to send verification email. Please try again.');
      }
    } else if (user == null) {
      throw Exception('No user logged in');
    } else {
      throw Exception('Email already verified');
    }
  }

  Future<bool> checkEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
        });
        return true;
      }
    }
    return false;
  }

  Future<UserModel?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }
}