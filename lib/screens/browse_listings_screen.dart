import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/book_card.dart';

class BrowseListingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Books'),
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          return StreamBuilder<List<BookModel>>(
            stream: bookProvider.getAllBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No books available'));
              }
              
              final books = snapshot.data!;
              final currentUserId = context.read<AuthProvider>().user?.id;
              
              // Filter out current user's books
              final availableBooks = books.where((book) => 
                book.ownerId != currentUserId && book.status == SwapStatus.Available
              ).toList();
              
              if (availableBooks.isEmpty) {
                return Center(child: Text('No books available for swap'));
              }
              
              return ListView.builder(
                itemCount: availableBooks.length,
                itemBuilder: (context, index) {
                  final book = availableBooks[index];
                  return BookCard(
                    book: book,
                    onSwap: () => _initiateSwap(context, book),
                  );
                },
              );
            },
          );
        },
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