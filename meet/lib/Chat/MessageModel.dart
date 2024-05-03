import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  MessageModel({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp
  });

  // Convert to map (key-value pair)
  Map<String, dynamic> toMap(){
    return{
      'senderID': senderID,
      // 'senderEmail': senderEmail, // CORRECT ONE???
      'senderEmail': senderID,
      'receiverID':receiverID,
      'message':message,
      'timestamp':timestamp
    };
  }
}