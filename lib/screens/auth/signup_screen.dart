import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _universityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: Duration(milliseconds: 1500), vsync: this);
    _slideController = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Back Button
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.8)],
                        ).createShader(bounds),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: AppTheme.accentColor.withOpacity(0.3),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Join the BookSwap community today',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 40),
                      // Premium Signup Form
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 40,
                              offset: Offset(0, 20),
                            ),
                            BoxShadow(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                validator: (value) => value?.isEmpty ?? true ? 'Enter your name' : null,
                              ),
                              SizedBox(height: 20),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                validator: (value) => value?.isEmpty ?? true ? 'Enter email' : null,
                              ),
                              SizedBox(height: 20),
                              _buildTextField(
                                controller: _universityController,
                                label: 'University/Institution',
                                icon: Icons.school_outlined,
                                validator: (value) => value?.isEmpty ?? true ? 'Enter your university' : null,
                              ),
                              SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Enter password';
                                  if (value!.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                isConfirmPassword: true,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) return 'Confirm your password';
                                  if (value != _passwordController.text) return 'Passwords do not match';
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),
                              // Terms Checkbox
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.2,
                                      child: Checkbox(
                                        value: _acceptTerms,
                                        onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        activeColor: AppTheme.accentColor,
                                        checkColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'I agree to the ',
                                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: TextStyle(
                                                color: AppTheme.accentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                color: AppTheme.accentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: _acceptTerms
                                          ? LinearGradient(
                                              colors: AppTheme.accentGradient,
                                            )
                                          : LinearGradient(
                                              colors: [AppTheme.surfaceColor, AppTheme.surfaceColor],
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: _acceptTerms
                                          ? [
                                              BoxShadow(
                                                color: AppTheme.accentColor.withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: authProvider.isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              color: _acceptTerms ? AppTheme.primaryColor : AppTheme.textTertiary,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: _acceptTerms
                                                ? () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      try {
                                                        await authProvider.signUp(
                                                          _emailController.text,
                                                          _passwordController.text,
                                                          _nameController.text,
                                                          _universityController.text,
                                                        );
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Account created! Please check your email for verification.'),
                                                            backgroundColor: AppTheme.successColor,
                                                            duration: Duration(seconds: 4),
                                                          ),
                                                        );
                                                        Navigator.pop(context);
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text(e.toString()),
                                                            backgroundColor: AppTheme.errorColor,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: _acceptTerms ? AppTheme.primaryColor : AppTheme.textTertiary,
                                              ),
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceColor),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword
            ? isConfirmPassword
                ? _obscureConfirmPassword
                : _obscurePassword
            : false,
        validator: validator,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppTheme.accentColor),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isConfirmPassword
                        ? (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility)
                        : (_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() {
                    if (isConfirmPassword) {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    } else {
                      _obscurePassword = !_obscurePassword;
                    }
                  }),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}