import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return users.join('_');
  }

  Future<void> createChatRoom(String user1, String user2) async {
    String chatRoomId = getChatRoomId(user1, user2);
    
    // Check if chat room already exists
    DocumentSnapshot doc = await _firestore.collection('chatRooms').doc(chatRoomId).get();
    if (doc.exists) {
      print('ChatService: Chat room already exists: $chatRoomId');
      return;
    }
    
    ChatRoom chatRoom = ChatRoom(
      id: chatRoomId,
      participants: [user1, user2],
    );
    
    print('ChatService: Creating chat room: $chatRoomId');
    await _firestore.collection('chatRooms').doc(chatRoomId).set(chatRoom.toMap());
    print('ChatService: Chat room created successfully');
  }

  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data()))
            .toList());
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String chatRoomId, String senderId, String receiverId, String message) async {
    try {
      String messageId = _firestore.collection('chatRooms').doc(chatRoomId).collection('messages').doc().id;
      
      ChatMessage chatMessage = ChatMessage(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
      );
      
      print('ChatService: Sending message to room $chatRoomId');
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(chatMessage.toMap());
      
      // Update chat room with last message
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      });
      
      print('ChatService: Message sent successfully');
    } catch (e) {
      print('ChatService: Error sending message: $e');
      throw e;
    }
  }

  Future<UserModel?> getUserInfo(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting user info: $e');
    }
    return null;
  }
}