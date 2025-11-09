import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import '../screens/browse_listings_screen.dart';
import '../screens/my_listings_screen.dart';
import '../screens/my_offers_screen.dart';
import '../screens/chats_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/add_book_screen.dart';
import '../providers/auth_provider.dart' as app_auth;
import 'package:provider/provider.dart';

class SharedLayout extends StatefulWidget {
  final int initialIndex;
  
  const SharedLayout({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _SharedLayoutState createState() => _SharedLayoutState();
}

class _SharedLayoutState extends State<SharedLayout> with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  
  final List<Widget> _screens = [
    BrowseListingsScreen(),
    MyListingsScreen(),
    MyOffersScreen(),
    ChatsScreen(),
    SettingsScreen(),
  ];

  final List<IconData> _inactiveIcons = [
    Icons.explore_outlined,
    Icons.library_books_outlined,
    Icons.swap_horiz_outlined,
    Icons.chat_bubble_outline,
    Icons.settings_outlined,
  ];

  final List<IconData> _activeIcons = [
    Icons.explore,
    Icons.library_books,
    Icons.swap_horiz,
    Icons.chat_bubble,
    Icons.settings,
  ];

  final List<String> _labels = [
    'Home',
    'My Listings',
    'My Offers',
    'Chats',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppTheme.accentColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppTheme.accentColor),
            onPressed: () {},
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) => _buildNavItem(index)),
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

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: AppTheme.accentGradient,
                )
              : null,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Icon(
                isSelected ? _activeIcons[index] : _inactiveIcons[index],
                key: ValueKey(isSelected),
                color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
                size: 26,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  _labels[index],
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'BookSwap',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.home, 'Home', () {
                  Navigator.pop(context);
                  _navigateToTab(0);
                }),
                _buildDrawerItem(Icons.library_books, 'My Listings', () {
                  Navigator.pop(context);
                  _navigateToTab(1);
                }),
                _buildDrawerItem(Icons.swap_horiz, 'My Offers', () {
                  Navigator.pop(context);
                  _navigateToTab(2);
                }),
                _buildDrawerItem(Icons.chat, 'Chats', () {
                  Navigator.pop(context);
                  _navigateToTab(3);
                }),
                _buildDrawerItem(Icons.settings, 'Settings', () {
                  Navigator.pop(context);
                  _navigateToTab(4);
                }),
                Divider(color: AppTheme.textTertiary),
                _buildDrawerItem(Icons.help, 'Help', () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(Icons.logout, 'Logout', () {
                  Navigator.pop(context);
                  Provider.of<app_auth.AuthProvider>(context, listen: false).signOut();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentColor),
      title: Text(
        title,
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      onTap: onTap,
      hoverColor: AppTheme.accentColor.withOpacity(0.1),
    );
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}