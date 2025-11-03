import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Stream<List<BookModel>> getAllBooks() {
    return _bookService.getAllBooks();
  }

  Stream<List<BookModel>> getUserBooks(String userId) {
    return _bookService.getUserBooks(userId);
  }

  Stream<List<BookModel>> getUserOffers(String userId) {
    return _bookService.getUserOffers(userId);
  }

  Future<void> createBook(BookModel book, File? imageFile) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _bookService.createBook(book, imageFile);
    } catch (e) {
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