import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skillbridge/models/message_model.dart';
import 'package:skillbridge/models/user_model.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getChatRoomId(String currentUserId, String receiverId) {
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    return ids.join('_');
  }

  Stream<List<MessageModel>> getMessages(String currentUserId, String receiverId) {
    String chatRoomId = _getChatRoomId(currentUserId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList();
        });
  }

  Future<void> sendMessage(String currentUserId, String receiverId, String content, MessageType type) async {
    String chatRoomId = _getChatRoomId(currentUserId, receiverId);
    
    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
    );

    // Save message
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());

    // Update recent chat tracker (for chat_list_screen)
    await _updateRecentChat(currentUserId, receiverId, content);
  }

  Future<void> _updateRecentChat(String currentUserId, String receiverId, String lastMessage) async {
    // Both users need a recent chat document
    final currentUserDoc = _firestore.collection('users').doc(currentUserId).collection('recentChats').doc(receiverId);
    final receiverUserDoc = _firestore.collection('users').doc(receiverId).collection('recentChats').doc(currentUserId);

    final timestamp = Timestamp.now();

    await currentUserDoc.set({
      'contactId': receiverId,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
    }, SetOptions(merge: true));

    await receiverUserDoc.set({
      'contactId': currentUserId,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> getRecentChats(String currentUserId) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('recentChats')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> recentChats = [];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final contactId = data['contactId'];
            
            // Get user info
            final userDoc = await _firestore.collection('users').doc(contactId).get();
            if (userDoc.exists) {
              data['contactUser'] = UserModel.fromMap(userDoc.data()!, userDoc.id);
            }
            recentChats.add(data);
          }
          return recentChats;
        });
  }
}

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository();
}
