import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble(
      {
        super.key,
        required this.message,
        required this.isCurrentUser,
      });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isCurrentUser ? 0 : 24,
          right: isCurrentUser ? 24 : 0),
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isCurrentUser
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
        const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: isCurrentUser
                ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            )
                : const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: isCurrentUser
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16, color: Colors.white))
          ],
        ),
      ),
    );


    // return Container(
    //   decoration: BoxDecoration(
    //     color: isCurrentUser ? Colors.purple : Colors.grey.shade500,
    //         borderRadius: BorderRadius.circular(12),
    //   ),
    //     padding: EdgeInsets.all(20),
    //     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
    //     child: Text(message, style: TextStyle(color: Colors.white),)
    // );


  }
}
