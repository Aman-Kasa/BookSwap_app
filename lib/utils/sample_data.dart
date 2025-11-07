import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class SampleDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addSampleBooks() async {
    print('Adding sample books to Firebase...');
    final sampleBooks = [
      {
        'title': 'The Picture of Dorian Gray',
        'author': 'Oscar Wilde',
        'condition': BookCondition.Good.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51jNORv6nQL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_1',
        'ownerName': 'Alice Johnson',
        'status': SwapStatus.Available.index,
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'condition': BookCondition.LikeNew.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/61NAx5pd6XL._SX342_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_2',
        'ownerName': 'Bob Smith',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'The Art of Seduction',
        'author': 'Robert Greene',
        'condition': BookCondition.Used.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51X7dEUFgoL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_3',
        'ownerName': 'Carol Davis',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'condition': BookCondition.Good.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51IXWZzlgSL._SX330_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_4',
        'ownerName': 'David Wilson',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'condition': BookCondition.LikeNew.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51XlnZhLlaL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_5',
        'ownerName': 'Emma Brown',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'Animal Farm',
        'author': 'George Orwell',
        'condition': BookCondition.Used.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51+5ZUzGtWL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_6',
        'ownerName': 'Frank Miller',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'The 48 Laws of Power',
        'author': 'Robert Greene',
        'condition': BookCondition.Good.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51NiGlapXlL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_7',
        'ownerName': 'Grace Lee',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'condition': BookCondition.LikeNew.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51wScUt0gEL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_8',
        'ownerName': 'Henry Clark',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'Brave New World',
        'author': 'Aldous Huxley',
        'condition': BookCondition.Used.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51p0kMLR6LL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_9',
        'ownerName': 'Ivy Chen',
        'status': SwapStatus.Available.index,
      },
      {
        'title': 'The Catcher in the Rye',
        'author': 'J.D. Salinger',
        'condition': BookCondition.Good.index,
        'imageUrl': 'https://images-na.ssl-images-amazon.com/images/I/51icVjlnzdL._SX331_BO1,204,203,200_.jpg',
        'ownerId': 'sample_user_10',
        'ownerName': 'Jack Thompson',
        'status': SwapStatus.Available.index,
      },
    ];

    for (var bookData in sampleBooks) {
      String bookId = _firestore.collection('books').doc().id;
      bookData['id'] = bookId;
      bookData['createdAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('books').doc(bookId).set(bookData);
      print('Added book: ${bookData['title']}');
    }
    print('All sample books added successfully!');
  }
}