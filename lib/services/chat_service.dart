import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // =========================
  // CURRENT USER
  // =========================

  String? get currentUserId =>
      _auth.currentUser?.uid;

  // =========================
  // CONVERSATION ID
  // =========================

  String getConversationId(
    String userId1,
    String userId2,
  ) {
    final ids = [
      userId1,
      userId2,
    ]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  // =========================
  // SEND MESSAGE
  // =========================

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final senderId = currentUserId;

    if (senderId == null) {
      throw Exception(
        'You must be signed in to send messages.',
      );
    }

    final cleanedMessage =
        message.trim();

    if (cleanedMessage.isEmpty) {
      return;
    }

    final conversationId =
        getConversationId(
      senderId,
      receiverId,
    );

    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'messageId': messageRef.id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': cleanedMessage,
      'timestamp':
          FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // GET MESSAGES
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getMessages(
    String otherUserId,
  ) {
    final senderId = currentUserId;

    if (senderId == null) {
      return const Stream.empty();
    }

    final conversationId =
        getConversationId(
      senderId,
      otherUserId,
    );

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: false,
        )
        .snapshots();
  }

  // =========================
  // GET OTHER USERS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getOtherUsers() {
    final currentId = currentUserId;

    if (currentId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .where(
          'uid',
          isNotEqualTo: currentId,
        )
        .snapshots();
  }
}