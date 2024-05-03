import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Chat/ChatPage.dart';

String getCurrentUserUsername() {
  User? user = FirebaseAuth.instance.currentUser;
  String? email = user?.email; // Assuming username is stored as displayName
  return email ?? 'No username available';
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  var searchName = "";
  var email = getCurrentUserUsername();
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  List<String> friendList = [];

  @override
  void initState() {
    super.initState();
    fetchFriendList(currentUserId ?? "").then((list) {
      setState(() {
        friendList = list;
      });
    });
  }

  Future<List<String>> fetchFriendList(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        // Check if the 'friendList' field exists in the user's document
        if (userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('friendList')) {
          // If 'friendList' exists, retrieve its value
          List<String> friendList = List<String>.from((userDoc.data() as Map<String, dynamic>)['friendList'] ?? []);
          return friendList;
        } else {
          // If 'friendList' doesn't exist, create an empty list and update the user's document
          List<String> friendList = [];
          await FirebaseFirestore.instance.collection('Users').doc(userId).update({
            'friendList': friendList,
          });
          return friendList;
        }
      } else {
        // If the user's document doesn't exist, create a new document with an empty 'friendList'
        List<String> friendList = [];
        await FirebaseFirestore.instance.collection('Users').doc(userId).set({
          'friendList': friendList,
        });
        return friendList;
      }
    } catch (e) {
      print('Error fetching friend list: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void addFriend(String friendUsername) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userDocRef);
      List<String> updatedFriendList = List.from(userDoc['friendList'] ?? []);

      if (!updatedFriendList.contains(friendUsername)) {
        updatedFriendList.add(friendUsername);
        transaction.update(userDocRef, {'friendList': updatedFriendList});
        setState(() {
          friendList = updatedFriendList;
        });
      }
    });
  }

  void removeFriend(String friendUsername) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userDocRef);
      List<String> updatedFriendList = List.from(userDoc['friendList'] ?? []);

      if (updatedFriendList.contains(friendUsername)) {
        updatedFriendList.remove(friendUsername);
        transaction.update(userDocRef, {'friendList': updatedFriendList});
        setState(() {
          friendList = updatedFriendList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        title: SizedBox(
          height: 40,
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchName = value;
              });
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: 'Search by Username',
                hintStyle: TextStyle(color: Colors.grey.shade800),
                prefixIcon: Icon(Icons.search, color: Colors.grey,)
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").orderBy('username').startAt([searchName]).endAt([searchName + "\uf8ff"]).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong with search");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.length == 0) {
            return Center(child: Text('No Username Found'),);
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index];
                if (data['email'] == email) {
                  return Container();
                }
                bool isFriend = friendList.contains(data['username']);
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiverEmail: data['email'],
                            receiverID: data['uid'],
                            displayName: data['displayName'],
                          ),
                        ));
                  },
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(data['photourl']),
                  ),
                  title: Text(data['displayName']),
                  subtitle: Text(data['username']),
                  trailing: isFriend ? IconButton(
                    icon: Icon(Icons.person, color: Colors.green),
                    onPressed: () {
                      removeFriend(data['username']);
                    },
                  ) : IconButton(
                    icon: Icon(Icons.person_add, color: Colors.green),
                    onPressed: () {
                      addFriend(data['username']);
                    },
                  ),
                );
              }
          );
        },
      ),
    );
  }
}