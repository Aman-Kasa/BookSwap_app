import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../models/book_model.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../services/sample_data_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;
  bool _swapAlertsEnabled = true;
  bool _chatNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
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
    return Container(
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
                        'Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings Content
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
                      
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            
                            // Profile Section
                            _buildSectionHeader('Profile Information'),
                            SizedBox(height: 16),
                            if (user != null) ...[
                              _buildProfileCard(user.name, user.email, user.university),
                              SizedBox(height: 32),
                            ],
                            
                            // Notification Settings
                            _buildSectionHeader('Notification Preferences'),
                            SizedBox(height: 16),
                            _buildToggleCard(
                              'Push Notifications',
                              'Receive notifications on your device',
                              Icons.notifications,
                              _notificationsEnabled,
                              (value) => setState(() => _notificationsEnabled = value),
                            ),
                            _buildToggleCard(
                              'Email Updates',
                              'Get updates via email',
                              Icons.email,
                              _emailUpdatesEnabled,
                              (value) => setState(() => _emailUpdatesEnabled = value),
                            ),
                            _buildToggleCard(
                              'Swap Alerts',
                              'Notifications for swap offers',
                              Icons.swap_horiz,
                              _swapAlertsEnabled,
                              (value) => setState(() => _swapAlertsEnabled = value),
                            ),
                            _buildToggleCard(
                              'Chat Messages',
                              'Notifications for new messages',
                              Icons.chat,
                              _chatNotificationsEnabled,
                              (value) => setState(() => _chatNotificationsEnabled = value),
                            ),
                            
                            SizedBox(height: 32),
                            
                            // App Settings
                            _buildSectionHeader('App Settings'),
                            SizedBox(height: 16),
                            _buildActionCard('Add Sample Books', Icons.library_add, () => _addSampleBooks(context)),
                            _buildActionCard('Create Test Book', Icons.book_outlined, () => _testSwapOffer(context)),
                            _buildActionCard('Reset Pending Books', Icons.refresh_outlined, () => _resetPendingBooks(context)),
                            _buildActionCard('Clear Cache', Icons.refresh, () => _clearCache(context)),
                            _buildActionCard('Privacy Policy', Icons.privacy_tip, () => _showPrivacyPolicy(context)),
                            _buildActionCard('Terms of Service', Icons.description, () => _showTermsOfService(context)),
                            _buildActionCard('Help & Support', Icons.help, () => _showHelpSupport(context)),
                            _buildActionCard('About BookSwap', Icons.info, () => _showAboutApp(context)),
                            
                            SizedBox(height: 32),
                            
                            // Account Actions
                            _buildSectionHeader('Account'),
                            SizedBox(height: 16),
                            _buildActionCard('Change Password', Icons.lock, () => _showChangePassword(context)),
                            _buildActionCard('Delete Account', Icons.delete_forever, () => _showDeleteAccount(context), isDestructive: true),
                            
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
                              child: ElevatedButton.icon(
                                onPressed: () => _showSignOutDialog(context, authProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: Icon(Icons.logout, color: Colors.white),
                                label: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 40),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildProfileCard(String name, String email, String university) {
    return Container(
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.accentGradient),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppTheme.primaryColor, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  university,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentColor,
            activeTrackColor: AppTheme.accentColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isDestructive 
                ? LinearGradient(colors: [AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.8)])
                : LinearGradient(colors: AppTheme.accentGradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon, 
            color: isDestructive ? Colors.white : AppTheme.primaryColor, 
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textTertiary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Privacy Policy', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Text(
            'BookSwap Privacy Policy\n\n'
            '1. Information Collection\n'
            'We collect information you provide when creating an account, including name, email, and university details.\n\n'
            '2. Data Usage\n'
            'Your data is used to facilitate book swapping between students and improve our services.\n\n'
            '3. Data Security\n'
            'We implement security measures to protect your personal information.\n\n'
            '4. Contact\n'
            'For privacy concerns, contact: a.kasa@alustudent.com',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Terms of Service', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Text(
            'BookSwap Terms of Service\n\n'
            '1. Acceptance\n'
            'By using BookSwap, you agree to these terms.\n\n'
            '2. User Responsibilities\n'
            'Users must provide accurate book information and treat others respectfully.\n\n'
            '3. Book Swapping\n'
            'All swaps are between users. BookSwap facilitates connections only.\n\n'
            '4. Account Termination\n'
            'We reserve the right to terminate accounts for violations.\n\n'
            'Contact: a.kasa@alustudent.com',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Help & Support', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Need help? Contact us:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildContactInfo(Icons.email, 'Email', 'a.kasa@alustudent.com'),
              _buildContactInfo(Icons.phone, 'Phone', '+250798694600'),
              _buildContactInfo(Icons.school, 'University', 'African Leadership University'),
              SizedBox(height: 16),
              Text('Common Issues:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Email verification not received\n• Book images not uploading\n• Chat messages not sending\n• Swap offers not appearing', 
                style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('About BookSwap', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppTheme.accentGradient),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_book, size: 40, color: AppTheme.primaryColor),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text('BookSwap v1.0', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 16),
              Text('A mobile application for students to exchange textbooks through a marketplace system with real-time chat functionality.', 
                style: TextStyle(color: AppTheme.textSecondary)),
              SizedBox(height: 16),
              Text('Developer:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildContactInfo(Icons.person, 'Name', 'Aman Kasa'),
              _buildContactInfo(Icons.email, 'Email', 'a.kasa@alustudent.com'),
              _buildContactInfo(Icons.phone, 'Phone', '+250798694600'),
              _buildContactInfo(Icons.school, 'University', 'African Leadership University'),
              SizedBox(height: 16),
              Text('Features:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Firebase Authentication\n• Real-time Chat System\n• Book CRUD Operations\n• Swap Management\n• Premium Dark UI', 
                style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Change Password', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textTertiary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textTertiary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textTertiary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.accentColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (_newPasswordController.text == _confirmPasswordController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password change functionality coming soon!'),
                    backgroundColor: AppTheme.accentColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passwords do not match!'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: Text('Change', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 16),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _addSampleBooks(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accentColor),
            SizedBox(height: 16),
            Text('Adding sample books...', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );

    try {
      await SampleDataService.populateSampleBooks();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sample books added successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding sample books: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _testSwapOffer(BuildContext context) async {
    try {
      final authProvider = context.read<app_auth.AuthProvider>();
      final user = authProvider.user;
      
      if (user != null) {
        // Create a test book first
        final bookProvider = context.read<BookProvider>();
        final testBook = BookModel(
          id: '',
          title: 'Test Swap Book',
          author: 'Test Author',
          condition: BookCondition.Good,
          imageUrl: '',
          ownerId: 'test_owner_${DateTime.now().millisecondsSinceEpoch}',
          ownerName: 'Test Owner',
          status: SwapStatus.Available,
          createdAt: DateTime.now(),
        );
        
        await bookProvider.createBook(testBook, null);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test book created! Now try swapping it.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating test book: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _resetPendingBooks(BuildContext context) async {
    try {
      // Reset all pending books to available
      final firestore = FirebaseFirestore.instance;
      final booksQuery = await firestore.collection('books').where('status', isEqualTo: 1).get(); // 1 = Pending
      
      for (var doc in booksQuery.docs) {
        await doc.reference.update({
          'status': 0, // Available
          'swapRequesterId': null,
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset ${booksQuery.docs.length} pending books to available'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting books: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _clearCache(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.accentColor),
            SizedBox(height: 16),
            Text('Clearing cache...', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );

    try {
      await context.read<BookProvider>().clearCache();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache cleared! Please restart the app.'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing cache: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showSignOutDialog(BuildContext context, app_auth.AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Sign Out', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await authProvider.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signed out successfully!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Delete Account', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor, size: 48),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone. All your books, chats, and swap offers will be permanently deleted.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion functionality coming soon!'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}