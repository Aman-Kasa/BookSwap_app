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
      UploadTask uploadTask = ref.putData(Uint8List.fromList(imageBytes));
      
      // Add timeout
      TaskSnapshot snapshot = await uploadTask.timeout(Duration(seconds: 30));
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image bytes uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image bytes: $e');
      // Return empty string instead of throwing to continue without image
      return '';
    }
  }

  Future<void> createBookSimple(BookModel book) async {
    try {
      print('BookService: Starting simple book creation');
      String bookId = _firestore.collection('books').doc().id;
      print('BookService: Generated book ID: $bookId');
      print('BookService: Image data length: ${book.imageUrl.length}');
      
      BookModel newBook = book.copyWith(id: bookId);
      print('BookService: Saving book to Firestore with image data');
      await _firestore.collection('books').doc(bookId).set(newBook.toMap());
      print('BookService: Book saved successfully!');
    } catch (e) {
      print('BookService: Error creating book: $e');
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