import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/book_model.dart';
import '../models/swap_offer_model.dart';
import '../widgets/book_card.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

class MyListingsScreen extends StatefulWidget {
  @override
  _MyListingsScreenState createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _editBook(BuildContext context, BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookScreen(book: book),
      ),
    );
  }

  void _deleteBook(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('Delete Book', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${book.title}"?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<BookProvider>().deleteBook(book.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Book deleted successfully!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting book: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: AppTheme.accentGradient,
                        ).createShader(bounds),
                        child: Text(
                          'My Listings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.sort,
                          color: AppTheme.accentColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          // Books List
                          Expanded(
                            child: Consumer<app_auth.AuthProvider>(
                              builder: (context, authProvider, child) {
                                if (authProvider.user == null) {
                                  return Center(child: Text('Please log in'));
                                }
                                
                                return StreamBuilder<List<BookModel>>(
                                  stream: context.read<BookProvider>().getUserBooks(authProvider.user!.id),
                                  builder: (context, snapshot) {
                                    print('StreamBuilder state: ${snapshot.connectionState}');
                                    print('StreamBuilder hasData: ${snapshot.hasData}');
                                    print('StreamBuilder data length: ${snapshot.data?.length ?? 0}');
                                    
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
                                    }
                                    
                                    if (snapshot.hasError) {
                                      print('StreamBuilder error: ${snapshot.error}');
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error, color: Colors.red, size: 48),
                                            SizedBox(height: 16),
                                            Text('Error loading books: ${snapshot.error}'),
                                          ],
                                        ),
                                      );
                                    }
                                    
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(40),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: AppTheme.accentGradient),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.accentColor.withOpacity(0.3),
                                                  blurRadius: 30,
                                                  offset: Offset(0, 15),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.library_books,
                                              size: 80,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                          Text(
                                            'No Books Listed Yet',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Add your first book to start\nswapping with other students',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppTheme.textSecondary,
                                              height: 1.5,
                                            ),
                                          ),
                                          SizedBox(height: 40),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: AppTheme.accentGradient),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.accentColor.withOpacity(0.4),
                                                  blurRadius: 20,
                                                  offset: Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => AddBookScreen()),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              icon: Icon(Icons.add, color: AppTheme.primaryColor),
                                              label: Text(
                                                'Add Your First Book',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    
                                    // Show user's books
                                    List<BookModel> userBooks = snapshot.data!;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Your Books',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            Spacer(),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: AppTheme.accentGradient),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${userBooks.length} books',
                                                style: TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Expanded(
                                          child: ListView.builder(
                                            padding: EdgeInsets.only(bottom: 100),
                                            itemCount: userBooks.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.only(bottom: 16),
                                                child: BookCard(
                                                  book: userBooks[index],
                                                  isOwner: true,
                                                  onEdit: () => _editBook(context, userBooks[index]),
                                                  onDelete: () => _deleteBook(context, userBooks[index]),
                                                  onAcceptSwap: userBooks[index].status == SwapStatus.Pending 
                                                      ? () => _acceptSwap(context, userBooks[index]) 
                                                      : null,
                                                  onRejectSwap: userBooks[index].status == SwapStatus.Pending 
                                                      ? () => _rejectSwap(context, userBooks[index]) 
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppTheme.accentGradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddBookScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icon(Icons.add, color: AppTheme.primaryColor),
          label: Text(
            'Add Book',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _acceptSwap(BuildContext context, BookModel book) async {
    try {
      // Find the swap offer for this book
      final authProvider = context.read<app_auth.AuthProvider>();
      final swapProvider = context.read<SwapProvider>();
      
      // Get received offers to find the one for this book
      final offers = await swapProvider.getReceivedSwapOffers(authProvider.user!.id).first;
      final offer = offers.firstWhere((o) => o.bookId == book.id);
      
      await swapProvider.respondToSwapOffer(offer.id, OfferStatus.accepted);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Swap offer accepted!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting swap: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _rejectSwap(BuildContext context, BookModel book) async {
    try {
      final authProvider = context.read<app_auth.AuthProvider>();
      final swapProvider = context.read<SwapProvider>();
      
      // Get received offers to find the one for this book
      final offers = await swapProvider.getReceivedSwapOffers(authProvider.user!.id).first;
      final offer = offers.firstWhere((o) => o.bookId == book.id);
      
      await swapProvider.respondToSwapOffer(offer.id, OfferStatus.rejected);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Swap offer rejected!'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting swap: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}