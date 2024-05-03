import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet/Chat/MessageModel.dart';

// For direct messages services
class ChatService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List Users:
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();
        //return user
        return user;
      }).toList();
    });
  }

  // Send message
  Future<void> sendMessage(String receiverID, message) async {
    // User info
    final String currentUserID = firebaseAuth.currentUser!.uid;
    final String currentUserEmail = firebaseAuth.currentUser!.email!;
    final Timestamp timeStamp = Timestamp.now();

    // Create new message
    MessageModel newMessage = MessageModel(
      senderID: currentUserID,
      // senderID: currentUserEmail,
      senderEmail: currentUserEmail,
      // senderEmail: currentUserID,
      receiverID: receiverID,
      message: message,
      timestamp: timeStamp,
    );

    // Make a chat room between people
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String roomChatID = ids.join("_");
    await firestore
        .collection("chat_rooms")
        .doc(roomChatID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // Get message
  Stream<QuerySnapshot> getMessages(String userID1, String userID2) {
    // Create 2 users chat room
    List<String> ids = [userID1, userID2];
    ids.sort();
    String chatRoomID = ids.join("_");

    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // TRYING: Another way to get chats from users...
  getPrivateChats (String userID1, String userID2) async {
    List<String> ids = [userID1, userID2];
    ids.sort();
    String chatRoomID = ids.join("_");
    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}

// https://youtu.be/5xU5WH2kEc0 AT SEND/RECEIVE MESSAGES!!!!
