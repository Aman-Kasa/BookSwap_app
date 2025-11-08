import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  bool _isLoading = false;
  List<BookModel> _books = [];

  bool get isLoading => _isLoading;
  List<BookModel> get books => _books;

  BookProvider() {
    _loadBooks();
  }

  void _loadBooks() {
    _bookService.getAllBooks().listen((books) {
      _books = books;
      notifyListeners();
    }).onError((error) {
      print('Error loading books: $error');
    });
  }

  Stream<List<BookModel>> getAllBooks() {
    return _bookService.getAllBooks();
  }

  Stream<List<BookModel>> getUserBooks(String userId) {
    print('BookProvider: Getting user books for userId: $userId');
    return _bookService.getUserBooks(userId);
  }

  Stream<List<BookModel>> getUserOffers(String userId) {
    return _bookService.getUserOffers(userId);
  }

  Future<void> createBook(BookModel book, File? imageFile) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('BookProvider: Creating book ${book.title}');
      await _bookService.createBook(book, imageFile);
      print('BookProvider: Book created successfully');
    } catch (e) {
      print('BookProvider: Error creating book: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBook(BookModel book, File? imageFile) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _bookService.updateBook(book, imageFile);
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _bookService.deleteBook(bookId);
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initiateSwap(String bookId, String requesterId) async {
    try {
      await _bookService.initiateSwap(bookId, requesterId);
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateSwapStatus(String bookId, SwapStatus status) async {
    try {
      await _bookService.updateSwapStatus(bookId, status);
    } catch (e) {
      throw e;
    }
  }
}