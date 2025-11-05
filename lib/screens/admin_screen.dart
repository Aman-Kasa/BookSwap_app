import 'package:flutter/material.dart';
import '../services/sample_data_service.dart';
import '../utils/app_theme.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppTheme.accentColor,
              ),
              SizedBox(height: 24),
              Text(
                'Admin Controls',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await SampleDataService.populateSampleBooks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sample books added successfully!'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.library_add),
                label: Text('Add Sample Books'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'This will add famous books by Osho, Oscar Wilde,\\nAgatha Christie, and Arthur Conan Doyle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}