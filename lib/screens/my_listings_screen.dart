import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_card.dart';
import 'add_book_screen.dart';

class MyListingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Books'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'My Listings'),
              Tab(text: 'My Offers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyListings(context),
            _buildMyOffers(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddBookScreen()),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMyListings(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return Center(child: Text('Please login'));

    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        return StreamBuilder<List<BookModel>>(
          stream: bookProvider.getUserBooks(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No books listed'));
            }
            
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final book = snapshot.data![index];
                return BookCard(
                  book: book,
                  isOwner: true,
                  onEdit: () => _editBook(context, book),
                  onDelete: () => _deleteBook(context, book),
                  onAcceptSwap: book.status == SwapStatus.Pending 
                      ? () => _updateSwapStatus(context, book, SwapStatus.Accepted)
                      : null,
                  onRejectSwap: book.status == SwapStatus.Pending
                      ? () => _updateSwapStatus(context, book, SwapStatus.Rejected)
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMyOffers(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return Center(child: Text('Please login'));

    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        return StreamBuilder<List<BookModel>>(
          stream: bookProvider.getUserOffers(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No swap offers'));
            }
            
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final book = snapshot.data![index];
                return BookCard(book: book, isOffer: true);
              },
            );
          },
        );
      },
    );
  }

  void _editBook(BuildContext context, BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(book: book),
      ),
    );
  }

  void _deleteBook(BuildContext context, BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<BookProvider>().deleteBook(book.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _updateSwapStatus(BuildContext context, BookModel book, SwapStatus status) async {
    try {
      await context.read<BookProvider>().updateSwapStatus(book.id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Swap ${status.name.toLowerCase()}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}