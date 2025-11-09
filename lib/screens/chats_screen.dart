import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/chat_provider.dart';
import '../screens/chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with TickerProviderStateMixin {
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
                          'Chats',
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
                          Icons.search,
                          color: AppTheme.accentColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat Content
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
                          // Chat Rooms List
                          Expanded(
                            child: Consumer<app_auth.AuthProvider>(
                              builder: (context, authProvider, child) {
                                if (authProvider.user == null) {
                                  return Center(child: Text('Please log in'));
                                }
                                
                                return StreamBuilder<List<ChatRoom>>(
                                  stream: context.read<ChatProvider>().getUserChatRooms(authProvider.user!.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
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
                                              Icons.chat_bubble_outline,
                                              size: 80,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                          Text(
                                            'No Conversations Yet',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Start swapping books to begin\nconversations with other students',
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
                                                // Navigate to browse books tab
                                                DefaultTabController.of(context)?.animateTo(0);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              icon: Icon(Icons.explore, color: AppTheme.primaryColor),
                                              label: Text(
                                                'Browse Books',
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
                                    
                                    // Show chat rooms
                                    List<ChatRoom> chatRooms = snapshot.data!;
                                    return ListView.builder(
                                      itemCount: chatRooms.length,
                                      itemBuilder: (context, index) {
                                        ChatRoom chatRoom = chatRooms[index];
                                        String otherUserId = '';
                                        
                                        // Safely find the other user ID
                                        try {
                                          otherUserId = chatRoom.participants
                                              .firstWhere((id) => id != authProvider.user!.id);
                                        } catch (e) {
                                          // If no other user found, skip this chat room
                                          return SizedBox.shrink();
                                        }
                                        
                                        // Skip if otherUserId is empty
                                        if (otherUserId.isEmpty) {
                                          return SizedBox.shrink();
                                        }
                                        
                                        return FutureBuilder(
                                          future: context.read<ChatProvider>().getUserInfo(otherUserId),
                                          builder: (context, userSnapshot) {
                                            String userName = 'User';
                                            String userInitial = 'U';
                                            
                                            if (userSnapshot.hasData && userSnapshot.data != null) {
                                              userName = userSnapshot.data!.name;
                                              userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
                                            }
                                            
                                            return Container(
                                              margin: EdgeInsets.only(bottom: 16),
                                              decoration: BoxDecoration(
                                                color: AppTheme.surfaceColor,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                contentPadding: EdgeInsets.all(16),
                                                leading: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: AppTheme.accentColor,
                                                  child: Text(
                                                    userInitial,
                                                    style: TextStyle(
                                                      color: AppTheme.primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  userName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.textPrimary,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 4),
                                                    Text(
                                                      chatRoom.lastMessage ?? 'No messages yet',
                                                      style: TextStyle(
                                                        color: AppTheme.textSecondary,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (chatRoom.lastMessageTime != null)
                                                      Text(
                                                        _formatChatTime(chatRoom.lastMessageTime!),
                                                        style: TextStyle(
                                                          color: AppTheme.textTertiary,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                trailing: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accentColor.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: AppTheme.accentColor,
                                                    size: 16,
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ChatDetailScreen(
                                                        chatRoomId: chatRoom.id,
                                                        otherUserId: otherUserId,
                                                        otherUserName: userName,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatChatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}