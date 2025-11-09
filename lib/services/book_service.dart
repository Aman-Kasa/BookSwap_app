import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/book_model.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .snapshots()
        .map((snapshot) {
          List<BookModel> books = snapshot.docs
              .map((doc) => BookModel.fromMap(doc.data()))
              .toList();
          // Sort locally instead of in Firestore
          books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return books;
        });
  }

  Stream<List<BookModel>> getUserBooks(String userId) {
    print('BookService: Querying books for userId: $userId');
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('BookService: Found ${snapshot.docs.length} books for user');
          List<BookModel> books = snapshot.docs
              .map((doc) {
                print('BookService: Book data: ${doc.data()}');
                return BookModel.fromMap(doc.data());
              })
              .toList();
          // Sort locally instead of in Firestore
          books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return books;
        });
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
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  Future<String> uploadImageBytes(List<int> imageBytes, String bookId) async {
    try {
      print('Starting image upload with ${imageBytes.length} bytes');
      Reference ref = _storage.ref().child('book_images').child('$bookId.jpg');
      
      // Set metadata for better handling
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'bookId': bookId},
      );
      
      UploadTask uploadTask = ref.putData(Uint8List.fromList(imageBytes), metadata);
      
      // Add timeout and progress monitoring
      TaskSnapshot snapshot = await uploadTask.timeout(Duration(seconds: 60));
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image bytes uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image bytes: $e');
      // Return placeholder instead of empty string
      return 'https://via.placeholder.com/300x400?text=Book+Cover';
    }
  }

  Future<void> createBookSimple(BookModel book) async {
    try {
      String bookId = _firestore.collection('books').doc().id;
      BookModel newBook = book.copyWith(id: bookId);
      
      await _firestore.collection('books').doc(bookId).set({
        'id': newBook.id,
        'title': newBook.title,
        'author': newBook.author,
        'condition': newBook.condition.index,
        'imageBase64': newBook.imageUrl, // Store as base64
        'ownerId': newBook.ownerId,
        'ownerName': newBook.ownerName,
        'status': newBook.status.index,
        'createdAt': newBook.createdAt.millisecondsSinceEpoch,
        'swapRequesterId': newBook.swapRequesterId,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateBook(BookModel book, File? imageFile) async {
    try {
      await _firestore.collection('books').doc(book.id).update({
        'title': book.title,
        'author': book.author,
        'condition': book.condition.index,
        'imageBase64': book.imageUrl, // Store as base64
        'status': book.status.index,
      });
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