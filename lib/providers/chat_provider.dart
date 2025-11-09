import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _chatService.getUserChatRooms(userId);
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _chatService.getChatMessages(chatRoomId);
  }

  Future<void> createChatRoom(String user1, String user2) async {
    await _chatService.createChatRoom(user1, user2);
  }

  Future<void> sendMessage(String chatRoomId, String senderId, String receiverId, String message) async {
    await _chatService.sendMessage(chatRoomId, senderId, receiverId, message);
  }

  String getChatRoomId(String user1, String user2) {
    return _chatService.getChatRoomId(user1, user2);
  }

  Future<UserModel?> getUserInfo(String userId) async {
    return await _chatService.getUserInfo(userId);
  }
}