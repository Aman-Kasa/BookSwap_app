import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserId;
  final String otherUserName;

  ChatDetailScreen({
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userId = context.read<app_auth.AuthProvider>().user?.id;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chat')),
        body: Center(child: Text('Please login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showUserInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return StreamBuilder<List<ChatMessage>>(
                  stream: chatProvider.getChatMessages(widget.chatRoomId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No messages yet'));
                    }
                    
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final message = snapshot.data![index];
                        final isMe = message.senderId == userId;
                        
                        return Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.message,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatTime(message.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMe ? Colors.white70 : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final userId = context.read<app_auth.AuthProvider>().user?.id;
    if (userId == null) return;

    try {
      await context.read<ChatProvider>().sendMessage(
        widget.chatRoomId,
        userId,
        widget.otherUserId,
        message,
      );
      
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: ${e.toString()}')),
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showUserInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('User Information', style: TextStyle(color: AppTheme.textPrimary)),
        content: FutureBuilder(
          future: context.read<ChatProvider>().getUserInfo(widget.otherUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentColor),
                  SizedBox(height: 16),
                  Text('Loading user info...', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              );
            }
            
            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: AppTheme.errorColor, size: 48),
                  SizedBox(height: 16),
                  Text('Could not load user information', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              );
            }
            
            final user = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildUserInfoRow(Icons.person, 'Name', user.name),
                _buildUserInfoRow(Icons.email, 'Email', user.email),
                _buildUserInfoRow(Icons.school, 'University', user.university),
                if (user.phoneNumber.isNotEmpty)
                  _buildUserInfoRow(Icons.phone, 'Phone', user.phoneNumber),
                if (user.location.isNotEmpty)
                  _buildUserInfoRow(Icons.location_on, 'Location', user.location),
                _buildUserInfoRow(Icons.calendar_today, 'Member Since', _formatDate(user.joinedDate)),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 16),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value.isEmpty ? 'Not set' : value, style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}