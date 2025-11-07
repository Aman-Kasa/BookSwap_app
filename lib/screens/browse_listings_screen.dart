import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/book_model.dart';
import '../widgets/book_card.dart';
import '../providers/book_provider.dart';
import '../utils/sample_data.dart';

class BrowseListingsScreen extends StatefulWidget {
  @override
  _BrowseListingsScreenState createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoadingSample = false;
  
  List<BookModel> _localBooks = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _loadLocalBooks();
  }
  
  void _loadLocalBooks() {
    _localBooks = [
      BookModel(
        id: '1',
        title: 'The Picture of Dorian Gray',
        author: 'Oscar Wilde',
        condition: BookCondition.Good,
        imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51jNORv6nQL._SX331_BO1,204,203,200_.jpg',
        ownerId: 'user1',
        ownerName: 'Alice Johnson',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      BookModel(
        id: '2',
        title: '1984',
        author: 'George Orwell',
        condition: BookCondition.LikeNew,
        imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/61NAx5pd6XL._SX342_BO1,204,203,200_.jpg',
        ownerId: 'user2',
        ownerName: 'Bob Smith',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      BookModel(
        id: '3',
        title: 'The Art of Seduction',
        author: 'Robert Greene',
        condition: BookCondition.Used,
        imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51X7dEUFgoL._SX331_BO1,204,203,200_.jpg',
        ownerId: 'user3',
        ownerName: 'Carol Davis',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
      BookModel(
        id: '4',
        title: 'To Kill a Mockingbird',
        author: 'Harper Lee',
        condition: BookCondition.Good,
        imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51IXWZzlgSL._SX330_BO1,204,203,200_.jpg',
        ownerId: 'user4',
        ownerName: 'David Wilson',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 4)),
      ),
      BookModel(
        id: '5',
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        condition: BookCondition.LikeNew,
        imageUrl: 'https://m.media-amazon.com/images/I/81af+MCATTL._AC_UF1000,1000_QL80_.jpg',
        ownerId: 'user5',
        ownerName: 'Emma Brown',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      BookModel(
        id: '6',
        title: 'The 48 Laws of Power',
        author: 'Robert Greene',
        condition: BookCondition.Good,
        imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51NiGlapXlL._SX331_BO1,204,203,200_.jpg',
        ownerId: 'user6',
        ownerName: 'Grace Lee',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 6)),
      ),
      BookModel(
        id: '7',
        title: 'The Adventures of Sherlock Holmes',
        author: 'Arthur Conan Doyle',
        condition: BookCondition.Used,
        imageUrl: 'https://m.media-amazon.com/images/I/71aFt4+OTOL._AC_UF1000,1000_QL80_.jpg',
        ownerId: 'user7',
        ownerName: 'Henry Clark',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 7)),
      ),
      BookModel(
        id: '8',
        title: 'The Power of Now',
        author: 'Osho',
        condition: BookCondition.LikeNew,
        imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/61NAx5pd6XL._SX342_BO1,204,203,200_.jpg',
        ownerId: 'user8',
        ownerName: 'Ivy Chen',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 8)),
      ),
      BookModel(
        id: '9',
        title: 'Meditation: The First and Last Freedom',
        author: 'Osho',
        condition: BookCondition.Good,
        imageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41T0iBxY8FL._SX440_BO1,204,203,200_.jpg',
        ownerId: 'user9',
        ownerName: 'Jack Thompson',
        status: SwapStatus.Available,
        createdAt: DateTime.now().subtract(Duration(days: 9)),
      ),
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: AppTheme.accentGradient,
                            ).createShader(bounds),
                            child: Text(
                              'Browse Listings',
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
                              Icons.filter_list,
                              color: AppTheme.accentColor,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search books, authors, or subjects...',
                            hintStyle: TextStyle(color: AppTheme.textTertiary),
                            prefixIcon: Icon(Icons.search, color: AppTheme.accentColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Books Grid
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
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Available Books',
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
                                  '${_localBooks.length} books',
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
                              itemCount: _localBooks.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300 + (index * 100)),
                                    curve: Curves.easeOutBack,
                                    child: BookCard(
                                      book: _localBooks[index],
                                    ),
                                  ),
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
            // Navigate to add book screen
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
}