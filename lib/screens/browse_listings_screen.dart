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
                    
                    if (availableBooks.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: availableBooks.length,
                      itemBuilder: (context, index) {
                        final book = availableBooks[index];
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