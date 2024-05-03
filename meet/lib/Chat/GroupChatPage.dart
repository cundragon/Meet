
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'DatabaseService.dart';
import 'GroupInfo.dart';
import 'MessageTile.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const GroupChatPage(
      {Key? key,
        required this.groupId,
        required this.groupName,
        required this.userName})
      : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  Stream<QuerySnapshot>? chats;

  TextEditingController messageController = TextEditingController();
  String adminName = "";
  FocusNode focusNode = FocusNode();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getChatandAdmin();

    // add listener to focus node
    focusNode.addListener(() {
      if (focusNode.hasFocus){
        Future.delayed(
          Duration(milliseconds: 100),
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

  void getChatandAdmin() async {
    await DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
        isLoading = false;
      });
    });
    await DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        adminName = val;
      });
    });
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
  void sendMessage  ()  {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => GroupInfo(
                  groupName: widget.groupName,
                  groupId: widget.groupId,
                  adminName: adminName,
                ))
                );},
              icon: const Icon(Icons.info))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading ? buildLoadingIndicator() : chatMessages(),
          ),
          buildUserInput(),
        ],
      )
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


  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // Scroll down to the bottom
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          scrollDown();
        });

        return snapshot.hasData
            ? ListView.builder(
          controller: scrollController,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
                message: snapshot.data.docs[index]['message'],
                sender: snapshot.data.docs[index]['sender'],
                sentByMe: widget.userName ==
                    snapshot.data.docs[index]['sender']);
          },
        )
            : Container();
      },
    );
  }

  Widget buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }


}

