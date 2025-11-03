import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          return ListView(
            children: [
              // Profile Section
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      if (user != null) ...[
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Name'),
                          subtitle: Text(user.name),
                        ),
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text('Email'),
                          subtitle: Text(user.email),
                        ),
                        ListTile(
                          leading: Icon(Icons.verified),
                          title: Text('Email Verified'),
                          subtitle: Text(user.emailVerified ? 'Yes' : 'No'),
                          trailing: user.emailVerified
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : TextButton(
                                  onPressed: () async {
                                    await authProvider.sendEmailVerification();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Verification email sent')),
                                    );
                                  },
                                  child: Text('Verify'),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Notification Settings
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Preferences',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('Push Notifications'),
                        subtitle: Text('Receive notifications for new messages and swap updates'),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text('Email Notifications'),
                        subtitle: Text('Receive email updates for important activities'),
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Account Actions
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text('Sign Out'),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Sign Out'),
                              content: Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Sign Out'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true) {
                            await authProvider.signOut();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}