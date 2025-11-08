import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../utils/app_theme.dart';
import '../home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.accentColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 32),
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Consumer<app_auth.AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      'We have sent a verification email to:\n${FirebaseAuth.instance.currentUser?.email ?? "your email"}\n\nPlease check your email (including spam folder) and click the verification link.\n\nAfter clicking the link, return here and tap "I\'ve Verified My Email".',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    );
                  },
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isChecking
                        ? CircularProgressIndicator(color: AppTheme.primaryColor)
                        : Text(
                            'I\'ve Verified My Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _resendEmail,
                  child: Text(
                    'Resend Verification Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    context.read<app_auth.AuthProvider>().signOut();
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      bool isVerified = await context.read<app_auth.AuthProvider>().checkEmailVerified();
      if (isVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email not verified yet. Please check your email.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking verification: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }

    setState(() {
      _isChecking = false;
    });
  }

  void _resendEmail() async {
    try {
      await context.read<app_auth.AuthProvider>().sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent! Check spam folder if not received.'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print('Resend email error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}