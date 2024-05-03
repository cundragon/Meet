import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meet/Chat/ChatBubble.dart';
import 'package:meet/Chat/ChatService.dart';
import 'package:meet/Firebase/firebase_auth_services.dart';

import 'DatabaseService.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String displayName;
  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.displayName
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  Stream<QuerySnapshot>? privateChats;
  final TextEditingController messageController = TextEditingController();

  final ChatService chatService = ChatService();
  final FirebaseAuthService firebaseAuthService = FirebaseAuthService();

  // Textfield focus (so that the chat can be automatically scrolled to the bottom for newer messages)
  FocusNode focusNode = FocusNode();

  @override
  void initState(){
    super.initState();

    getChats();

    // add listener to focus node
    focusNode.addListener(() {
      if (focusNode.hasFocus){
        Future.delayed(
          Duration(milliseconds: 500),
            () => scrollDown(),
        );
      }
    });

    // Automatically scroll down to the last message when tapping on a user's chat room
    Future.delayed(Duration(milliseconds: 500), ()=>scrollDown());
  }

  @override
  void dispose(){
    focusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController scrollController = ScrollController();
  void scrollDown(){
    scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn
    );
  }

  // Send message
  void sendMessage() async{
    // As long as there is a message to send
    if(messageController.text.isNotEmpty){
      await chatService.sendMessage(widget.receiverID, messageController.text);
      // Clear text controller
      messageController.clear();
    }
    scrollDown();
  }

  // 1st TODO: define function get chats from both user
  void getChats() async{
    String senderID = firebaseAuthService.getUserNow()!.uid;
    await ChatService().getPrivateChats(widget.receiverID, senderID).then((val){
      setState(() {
        privateChats = val;
      });
    }
    );
  }

  // This will be when you clicked on the user to chat with!
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.displayName),
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(
              child: buildMessageList()
          ),

          buildUserInput(),
        ],
      )

    );
  }

  Widget buildMessageList(){
    String senderID = firebaseAuthService.getUserNow()!.uid;
    return StreamBuilder(
        // stream: chatService.getMessages(widget.receiverID, senderID),
        stream: privateChats,
        builder: (context, snapshot){
          // Error
          if (snapshot.hasError){
            return Text("Error");
          }
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading...");
          }

          // Scroll down to the bottom
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            scrollDown();
          });
          // List view
          return ListView(
            controller: scrollController,
            children: snapshot.data!.docs.map((doc) => buildMessageItem(doc)).toList(),
          );

        }
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Current User
    bool isCurrentUser = data['senderID'] == firebaseAuthService.getUserNow()!.uid;

    // Align the message to the right if sender is the current user, otherwise left
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(message: data["message"], isCurrentUser: isCurrentUser)
          ],
        ),
    );
  }

  Widget buildUserInput(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        children: [
          Expanded(
              child:Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: TextFormField(
                    controller: messageController,
                    textInputAction: TextInputAction.done,
                    cursorColor: Colors.deepPurple,
                    focusNode: focusNode,
                    obscureText: false, // Controls visibility based on the boolean state
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: ' Type a message',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0), // Adjust the padding here
                    ),
                  ),
                ),
              ),
          ),
          SizedBox(width: 10),
          Container(
            decoration:
            BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
              margin: EdgeInsets.only(right: 10),
              child: IconButton(onPressed: sendMessage, icon: Icon(Icons.arrow_upward, color: Colors.white,)))
        ],
      ),
    );
  }
}

