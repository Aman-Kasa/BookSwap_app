import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/book_card.dart';
import '../utils/app_theme.dart';

class BrowseListingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Listings'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: AppTheme.primaryColor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // Books List
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                return StreamBuilder<List<BookModel>>(
                  stream: bookProvider.getAllBooks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentColor,
                        ),
                      );
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    final books = snapshot.data!;
                    final currentUserId = context.read<AuthProvider>().user?.id;
                    
                    final availableBooks = books.where((book) => 
                      book.ownerId != currentUserId && book.status == SwapStatus.Available
                    ).toList();
                    
                    // Add sample books if empty
                    final displayBooks = availableBooks.isEmpty ? _getSampleBooks() : availableBooks;
                    
                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: displayBooks.length,
                      itemBuilder: (context, index) {
                        final book = displayBooks[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: BookCard(
                            book: book,
                            onSwap: () => _initiateSwap(context, book),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<BookModel> _getSampleBooks() {
    return [
      BookModel(
        id: 'sample1',
        title: 'The Picture of Dorian Gray',
        author: 'Oscar Wilde',
        condition: BookCondition.LikeNew,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780141439570-L.jpg',
        ownerId: 'sample_user_1',
        ownerName: 'Alice Johnson',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      BookModel(
        id: 'sample2',
        title: 'Murder on the Orient Express',
        author: 'Agatha Christie',
        condition: BookCondition.Good,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780062693662-L.jpg',
        ownerId: 'sample_user_2',
        ownerName: 'Bob Smith',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      BookModel(
        id: 'sample3',
        title: 'The Adventures of Sherlock Holmes',
        author: 'Arthur Conan Doyle',
        condition: BookCondition.Used,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780486474915-L.jpg',
        ownerId: 'sample_user_3',
        ownerName: 'Carol Davis',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      BookModel(
        id: 'sample4',
        title: 'The Book of Secrets',
        author: 'Osho',
        condition: BookCondition.New,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780312180584-L.jpg',
        ownerId: 'sample_user_4',
        ownerName: 'David Wilson',
        createdAt: DateTime.now().subtract(Duration(days: 4)),
      ),
      BookModel(
        id: 'sample5',
        title: 'And Then There Were None',
        author: 'Agatha Christie',
        condition: BookCondition.LikeNew,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780062073488-L.jpg',
        ownerId: 'sample_user_5',
        ownerName: 'Emma Brown',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      BookModel(
        id: 'sample6',
        title: 'The Hound of the Baskervilles',
        author: 'Arthur Conan Doyle',
        condition: BookCondition.Good,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780486282145-L.jpg',
        ownerId: 'sample_user_6',
        ownerName: 'Frank Miller',
        createdAt: DateTime.now().subtract(Duration(days: 6)),
      ),
      BookModel(
        id: 'sample7',
        title: 'The Importance of Being Earnest',
        author: 'Oscar Wilde',
        condition: BookCondition.New,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780486264783-L.jpg',
        ownerId: 'sample_user_7',
        ownerName: 'Grace Lee',
        createdAt: DateTime.now().subtract(Duration(days: 7)),
      ),
      BookModel(
        id: 'sample8',
        title: 'Death on the Nile',
        author: 'Agatha Christie',
        condition: BookCondition.Used,
        imageUrl: 'https://covers.openlibrary.org/b/isbn/9780062073556-L.jpg',
        ownerId: 'sample_user_8',
        ownerName: 'Henry Taylor',
        createdAt: DateTime.now().subtract(Duration(days: 8)),
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No books available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for new listings',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _initiateSwap(BuildContext context, BookModel book) async {
    final authProvider = context.read<AuthProvider>();
    final bookProvider = context.read<BookProvider>();
    final chatProvider = context.read<ChatProvider>();
    
    if (authProvider.user == null) return;
    
    try {
      await bookProvider.initiateSwap(book.id, authProvider.user!.id);
      await chatProvider.createChatRoom(authProvider.user!.id, book.ownerId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Swap request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}