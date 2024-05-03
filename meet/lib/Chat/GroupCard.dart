import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'MessagesLandingPage.dart';
import 'GroupChatPage.dart';

class GroupCard extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupCard(
      {Key? key,
        required this.groupId,
        required this.groupName,
        required this.userName,
      })
      : super(key: key);

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {

  void leaveGroup(String groupName) async {

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    DocumentReference groupsDocRef = FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Access group list FROM user
      DocumentSnapshot userDoc = await transaction.get(userDocRef);
      List<String> groupList = List.from(userDoc['groups'] ?? []);

      // Access members list FROM groups
      DocumentSnapshot groupsDoc = await transaction.get(groupsDocRef);
      List<String> membersList = List.from(groupsDoc['members'] ?? []);

      // NOTE: groupName is in the form of: groupID + "_" + groupName
      if (groupList.contains(groupName)) {
        // REMOVE group from user
        groupList.remove(groupName);
        transaction.update(userDocRef, {'groups': groupList});
      }

      if (membersList.contains(userId)){
        // REMOVE user as a member FROM the group
        membersList.remove(userId);
        transaction.update(groupsDocRef, {'members': membersList});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupChatPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
          userName: widget.userName,
        ))
        );

      },
      child: Container(
        decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.secondary,
          color: Colors.white,
          //borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon(Icons.group, color: Colors.white),
            // SizedBox(width: 17),
            // Expanded(
            //     child: Text(widget.groupName,style: TextStyle(color: Colors.white, fontSize: 25)),
            // ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle,),
              child: Icon(Icons.group, color: Colors.white, size: 30,),
            ),
            SizedBox(width: 17),
            Expanded(
              child: Text(widget.groupName, style: TextStyle(color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.w400,),),
            ),

            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.deepPurple, size: 30),
              onSelected: (String choice) {
                if (choice == 'leave_group') {
                  // TODO: Implement leave group functionality here
                  leaveGroup(widget.groupId + "_" + widget.groupName);
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'leave_group',
                    child: Text('Leave Group'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}