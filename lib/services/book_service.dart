import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<BookModel>> getUserBooks(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<BookModel>> getUserOffers(String userId) {
    return _firestore
        .collection('books')
        .where('swapRequesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromMap(doc.data()))
            .toList());
  }

  Future<String> uploadImage(File imageFile, String bookId) async {
    try {
      Reference ref = _storage.ref().child('book_images').child('$bookId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw e;
    }
  }

  Future<void> createBook(BookModel book, File? imageFile) async {
    try {
      String bookId = _firestore.collection('books').doc().id;
      String imageUrl = '';
      
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, bookId);
      }
      
      BookModel newBook = book.copyWith(id: bookId, imageUrl: imageUrl);
      await _firestore.collection('books').doc(bookId).set(newBook.toMap());
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateBook(BookModel book, File? imageFile) async {
    try {
      String imageUrl = book.imageUrl;
      
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, book.id);
      }
      
      BookModel updatedBook = book.copyWith(imageUrl: imageUrl);
      await _firestore.collection('books').doc(book.id).set(updatedBook.toMap());
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw e;
    }
  }

  Future<void> initiateSwap(String bookId, String requesterId) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'status': SwapStatus.Pending.index,
        'swapRequesterId': requesterId,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateSwapStatus(String bookId, SwapStatus status) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'status': status.index,
      });
    } catch (e) {
      throw e;
    }
  }
}