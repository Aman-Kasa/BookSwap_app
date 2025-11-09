import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/app_theme.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  
  BookCondition _selectedCondition = BookCondition.Good;
  String _imageBase64 = '';
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.backgroundColor],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(24),
                child: Row(
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
                    SizedBox(width: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: AppTheme.accentGradient,
                      ).createShader(bounds),
                      child: Text(
                        'Add Book',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          // Image Picker
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 150,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.accentColor, width: 2),
                                ),
                                child: _imageBase64.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.memory(
                                          base64Decode(_imageBase64),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : _isUploading
                                        ? Center(
                                            child: CircularProgressIndicator(color: AppTheme.accentColor),
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt, size: 40, color: AppTheme.accentColor),
                                              SizedBox(height: 8),
                                              Text('Add Cover Photo', style: TextStyle(color: AppTheme.accentColor)),
                                            ],
                                          ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          // Title Field
                          _buildTextField(
                            controller: _titleController,
                            label: 'Book Title',
                            icon: Icons.book,
                            validator: (value) => value?.isEmpty ?? true ? 'Enter book title' : null,
                          ),
                          SizedBox(height: 20),
                          // Author Field
                          _buildTextField(
                            controller: _authorController,
                            label: 'Author',
                            icon: Icons.person,
                            validator: (value) => value?.isEmpty ?? true ? 'Enter author name' : null,
                          ),
                          SizedBox(height: 20),
                          // Condition Selector
                          Text(
                            'Condition',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: BookCondition.values.map((condition) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedCondition = condition),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _selectedCondition == condition
                                            ? AppTheme.accentColor
                                            : AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getConditionText(condition),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _selectedCondition == condition
                                              ? AppTheme.primaryColor
                                              : AppTheme.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 40),
                          // Submit Button
                          Consumer<BookProvider>(
                            builder: (context, bookProvider, child) {
                              return Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: AppTheme.accentGradient),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentColor.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: bookProvider.isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme.primaryColor,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _submitBook,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          'Add Book',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppTheme.accentColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  String _getConditionText(BookCondition condition) {
    switch (condition) {
      case BookCondition.New:
        return 'New';
      case BookCondition.LikeNew:
        return 'Like New';
      case BookCondition.Good:
        return 'Good';
      case BookCondition.Used:
        return 'Used';
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await picked.readAsBytes();
      final base64Image = base64Encode(bytes);
      print('Image picked: ${bytes.length} bytes, base64 length: ${base64Image.length}');

      setState(() {
        _imageBase64 = base64Image;
        _isUploading = false;
      });
      
      print('Image base64 set successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = context.read<app_auth.AuthProvider>();
        final user = authProvider.user;
        
        if (user != null) {
          print('Add Book - Creating book for user: ${user.id} (${user.name})');
          final book = BookModel(
            id: '',
            title: _titleController.text,
            author: _authorController.text,
            condition: _selectedCondition,
            imageUrl: _imageBase64,
            ownerId: user.id,
            ownerName: user.name,
            status: SwapStatus.Available,
            createdAt: DateTime.now(),
          );

          print('Creating book: ${book.title} by ${book.author}');
          print('Book image URL length: ${book.imageUrl.length}');
          await context.read<BookProvider>().createBook(book, null);
          print('Book created successfully!');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Book added successfully!'),
              backgroundColor: AppTheme.accentColor,
            ),
          );
          
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error creating book: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}