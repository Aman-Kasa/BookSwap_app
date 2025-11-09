import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;
  bool _isUploading = false;
  String _imageBase64 = '';
  bool _imageChanged = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final user = context.read<app_auth.AuthProvider>().user;
    _locationController.text = user?.location ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _bioController.text = user?.bio ?? '';
    _imageBase64 = user?.profileImageUrl ?? '';
    
    _fadeController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: AppTheme.accentGradient,
                        ).createShader(bounds),
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppTheme.accentGradient),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(_isEditing ? Icons.save : Icons.edit, color: AppTheme.primaryColor),
                          onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Consumer<app_auth.AuthProvider>(
                      builder: (context, authProvider, child) {
                        final user = authProvider.user;
                        if (user == null) return Center(child: CircularProgressIndicator(color: AppTheme.accentColor));

                        return SingleChildScrollView(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              // Profile Picture
                              GestureDetector(
                                onTap: _isEditing ? _pickImage : null,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: AppTheme.accentGradient),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accentColor.withOpacity(0.4),
                                            blurRadius: 30,
                                            offset: Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: AppTheme.surfaceColor,
                                        child: _buildProfileImage(user.profileImageUrl),
                                      ),
                                    ),
                                    if (_isEditing)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: AppTheme.accentGradient),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.accentColor.withOpacity(0.4),
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Icon(Icons.camera_alt, color: AppTheme.primaryColor, size: 20),
                                        ),
                                      ),
                                    if (_isUploading)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(color: AppTheme.accentColor),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 40),
                              
                              // User Info Cards
                              _buildInfoCard('Name', user.name, Icons.person),
                              _buildInfoCard('Email', user.email, Icons.email),
                              _buildInfoCard('University', user.university, Icons.school),
                              _buildEditableCard('Phone', user.phoneNumber, Icons.phone, _phoneController),
                              _buildEditableCard('Location', user.location, Icons.location_on, _locationController),
                              _buildEditableCard('Bio', user.bio, Icons.info_outline, _bioController, maxLines: 3),
                              _buildInfoCard('Member Since', _formatDate(user.joinedDate), Icons.calendar_today),
                              
                              SizedBox(height: 40),
                              
                              // Sign Out Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.errorColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => authProvider.signOut(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.accentGradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text(value.isEmpty ? 'Not set' : value, 
                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(String label, String value, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.accentGradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _isEditing
                ? Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: controller,
                      maxLines: maxLines,
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Enter your $label',
                        hintStyle: TextStyle(color: AppTheme.textTertiary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      Text(value.isEmpty ? 'Not set' : value, 
                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildProfileImage(String currentImageUrl) {
    String displayImage = _imageChanged ? _imageBase64 : currentImageUrl;
    
    if (displayImage.isNotEmpty) {
      try {
        return ClipOval(
          child: Image.memory(
            base64Decode(displayImage.contains(',') ? displayImage.split(',')[1] : displayImage),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        return Icon(Icons.person, size: 60, color: AppTheme.accentColor);
      }
    }
    return Icon(Icons.person, size: 60, color: AppTheme.accentColor);
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      try {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        setState(() {
          _imageBase64 = base64Image;
          _imageChanged = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading image: $e')),
        );
      }
    }
  }

  void _saveProfile() async {
    setState(() => _isUploading = true);
    
    try {
      final user = context.read<app_auth.AuthProvider>().user!;
      String imageUrl = _imageChanged ? _imageBase64 : user.profileImageUrl;
      
      // Update user data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({
        'location': _locationController.text,
        'phoneNumber': _phoneController.text,
        'bio': _bioController.text,
        'profileImageUrl': imageUrl,
      });
      
      // Refresh user data
      await context.read<app_auth.AuthProvider>().getCurrentUserData();
      
      setState(() {
        _isEditing = false;
        _isUploading = false;
        _imageChanged = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated!'), backgroundColor: AppTheme.successColor),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
      );
    }
  }
}