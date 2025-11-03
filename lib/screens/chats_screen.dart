import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.id;
    
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chats')),
        body: Center(child: Text('Please login to view chats')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return StreamBuilder<List<ChatRoom>>(
            stream: chatProvider.getUserChatRooms(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No chats yet'));
              }
              
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final chatRoom = snapshot.data![index];
                  final otherUserId = chatRoom.participants
                      .firstWhere((id) => id != userId);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text('Chat with User'),
                    subtitle: chatRoom.lastMessage != null
                        ? Text(chatRoom.lastMessage!)
                        : Text('No messages yet'),
                    trailing: chatRoom.lastMessageTime != null
                        ? Text(_formatTime(chatRoom.lastMessageTime!))
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatRoomId: chatRoom.id,
                            otherUserId: otherUserId,
                          ),
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
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}