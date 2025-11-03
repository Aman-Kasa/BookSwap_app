import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';

class AddBookScreen extends StatefulWidget {
  final BookModel? book;

  AddBookScreen({this.book});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  BookCondition _selectedCondition = BookCondition.Good;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add Book'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter author' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<BookCondition>(
                value: _selectedCondition,
                decoration: InputDecoration(labelText: 'Condition'),
                items: BookCondition.values.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  SizedBox(width: 16),
                  if (_imageFile != null)
                    Text('Image selected')
                  else if (isEditing && widget.book!.imageUrl.isNotEmpty)
                    Text('Current image will be kept'),
                ],
              ),
              if (_imageFile != null)
                Container(
                  height: 200,
                  width: 200,
                  margin: EdgeInsets.symmetric(vertical: 16),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              Spacer(),
              Consumer<BookProvider>(
                builder: (context, bookProvider, child) {
                  return bookProvider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _saveBook,
                          child: Text(isEditing ? 'Update Book' : 'Add Book'),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final bookProvider = context.read<BookProvider>();
      
      if (authProvider.user == null) return;

      try {
        final book = BookModel(
          id: widget.book?.id ?? '',
          title: _titleController.text,
          author: _authorController.text,
          condition: _selectedCondition,
          imageUrl: widget.book?.imageUrl ?? '',
          ownerId: authProvider.user!.id,
          ownerName: authProvider.user!.name,
          createdAt: widget.book?.createdAt ?? DateTime.now(),
        );

        if (widget.book != null) {
          await bookProvider.updateBook(book, _imageFile);
        } else {
          await bookProvider.createBook(book, _imageFile);
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book ${widget.book != null ? 'updated' : 'added'} successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}