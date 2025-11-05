import '../models/book_model.dart';
import '../services/book_service.dart';

class SampleDataService {
  static final BookService _bookService = BookService();

  static final List<Map<String, dynamic>> _sampleBooks = [
    {
      'title': 'The Picture of Dorian Gray',
      'author': 'Oscar Wilde',
      'condition': BookCondition.LikeNew,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8225261-L.jpg',
      'ownerName': 'Alice Johnson',
    },
    {
      'title': 'Murder on the Orient Express',
      'author': 'Agatha Christie',
      'condition': BookCondition.Good,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8739161-L.jpg',
      'ownerName': 'Bob Smith',
    },
    {
      'title': 'The Adventures of Sherlock Holmes',
      'author': 'Arthur Conan Doyle',
      'condition': BookCondition.Used,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8225030-L.jpg',
      'ownerName': 'Carol Davis',
    },
    {
      'title': 'The Book of Secrets',
      'author': 'Osho',
      'condition': BookCondition.New,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8739162-L.jpg',
      'ownerName': 'David Wilson',
    },
    {
      'title': 'And Then There Were None',
      'author': 'Agatha Christie',
      'condition': BookCondition.LikeNew,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8225262-L.jpg',
      'ownerName': 'Emma Brown',
    },
    {
      'title': 'The Hound of the Baskervilles',
      'author': 'Arthur Conan Doyle',
      'condition': BookCondition.Good,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8225031-L.jpg',
      'ownerName': 'Frank Miller',
    },
    {
      'title': 'Meditation: The First and Last Freedom',
      'author': 'Osho',
      'condition': BookCondition.Used,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8739163-L.jpg',
      'ownerName': 'Grace Lee',
    },
    {
      'title': 'The Importance of Being Earnest',
      'author': 'Oscar Wilde',
      'condition': BookCondition.New,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8225263-L.jpg',
      'ownerName': 'Henry Taylor',
    },
    {
      'title': 'Death on the Nile',
      'author': 'Agatha Christie',
      'condition': BookCondition.LikeNew,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8739164-L.jpg',
      'ownerName': 'Ivy Chen',
    },
    {
      'title': 'A Study in Scarlet',
      'author': 'Arthur Conan Doyle',
      'condition': BookCondition.Good,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8225032-L.jpg',
      'ownerName': 'Jack Anderson',
    },
    {
      'title': 'The Power of Now',
      'author': 'Osho',
      'condition': BookCondition.Used,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8739165-L.jpg',
      'ownerName': 'Kate Roberts',
    },
    {
      'title': 'The Canterville Ghost',
      'author': 'Oscar Wilde',
      'condition': BookCondition.New,
      'imageUrl': 'https://covers.openlibrary.org/b/id/8225264-L.jpg',
      'ownerName': 'Liam Murphy',
    },
  ];

  static Future<void> populateSampleBooks() async {
    try {
      for (var bookData in _sampleBooks) {
        final book = BookModel(
          id: '',
          title: bookData['title'],
          author: bookData['author'],
          condition: bookData['condition'],
          imageUrl: bookData['imageUrl'],
          ownerId: 'sample_user_${bookData['ownerName'].toLowerCase().replaceAll(' ', '_')}',
          ownerName: bookData['ownerName'],
          createdAt: DateTime.now().subtract(
            Duration(days: _sampleBooks.indexOf(bookData) + 1),
          ),
        );
        
        await _bookService.createBook(book, null);
      }
    } catch (e) {
      print('Error populating sample books: $e');
    }
  }
}