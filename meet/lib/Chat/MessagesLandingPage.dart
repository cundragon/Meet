import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet/Chat/DatabaseService.dart';
import 'package:meet/Firebase/firebase_auth_services.dart';

import 'ChatPage.dart';
import 'ChatService.dart';
import 'GroupCard.dart';
import 'GroupInfo.dart';
import 'UserCard.dart';

class MessagesLandingPage extends StatefulWidget {
  MessagesLandingPage({super.key});
  @override
  State<MessagesLandingPage> createState() => _MessagesLandingPageState();
}

class _MessagesLandingPageState extends State<MessagesLandingPage> {
  int tabsIndex = 0;
  final List<Widget> tabs = [dmScreen(), GroupChatsScreen(), FindGroups()];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Chats", textAlign: TextAlign.center),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          bottom: TabBar(
            labelPadding: EdgeInsets.symmetric(vertical: 0.0),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.white, width: 5.0),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Contacts'),
              Tab(icon: Icon(Icons.group), text: 'Groups'),
              Tab(icon: Icon(Icons.search), text: 'Find Groups')
            ],
          ),
        ),

        body: TabBarView(
          children: tabs,
        ),
      ),
    );
  }
}

// DMSCREEN:
class dmScreen extends StatelessWidget {
  // Chat and authentication services
  final ChatService chatService = ChatService();
  final FirebaseAuthService firebaseAuthService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: chatService.getUsersStream(),
        builder: (context, snapshot) {
          // ERROR:
          if (snapshot.hasError) {
            return const Text("ERROR");
          }
          // LOADING...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("LOADING...");
          }
          // RETURN list view
          return FutureBuilder<List<Widget>>(
            future: Future.wait(snapshot.data!
                .map<Future<Widget>>((userData) => buildUserListItem(userData, context))
                .toList()),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return ListView(
                children: futureSnapshot.data ?? [],
              );
            },
          );
        });
  }

  Future<Widget> buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) async {
    List<String> friendList = [];
    // display all users except 'yourself'
    String currentUserID = firebaseAuthService.getUserNow()!.uid;
    DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(currentUserID);
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(currentUserID).get();
    if (userDoc.exists) {
      // Check if the 'friendList' field exists in the user's document
      if (userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('friendList')) {
        // If 'friendList' exists, retrieve its value
        friendList = List<String>.from((userDoc.data() as Map<String, dynamic>)['friendList'] ?? []);
      } else {
        // If 'friendList' doesn't exist, create an empty list and update the user's document
        friendList = [];
        await FirebaseFirestore.instance.collection('Users').doc(currentUserID).update({
          'friendList': friendList,
        });
      }
    }
    if (friendList.contains(userData['username']) && userData['email'] != firebaseAuthService.getUserNow()!.email) {
      return ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(userData['photourl']),
        ),
        title: Text(userData['displayName']),
        subtitle: Text(userData['username']),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle),
          onPressed: () async {
            // Remove the user from the current user's friendList
            friendList.remove(userData['username']);
            await userRef.update({'friendList': friendList});
          },
        ),
        onTap: () {
          //tapped on a user -> go to chat page
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverEmail: userData['email'],
                  receiverID: userData['uid'],
                  displayName: userData['displayName'],
                ),
              ));
        },
      );
    } else {
      return Container();
    }
  }
}

// GROUP CHAT:
class GroupChatsScreen extends StatefulWidget {
  @override
  State<GroupChatsScreen> createState() => _GroupChatsScreenState();
}

class _GroupChatsScreenState extends State<GroupChatsScreen> {
  Stream? groups;
  // Create a drop down menu:
  static const List<String> privacyList = <String>['Private','Public'];
  String selectedPrivacyOption = privacyList.first;

  @override
  void initState() {
    super.initState();
    fetchUserGroups();
  }

  // Fetch User groups
  fetchUserGroups() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  String userName = '';

  // To obtain the group name from user input
  String groupName = '';
  final groupNameTextController = TextEditingController();

  @override
  void dispose() {
    groupNameTextController.dispose();
    super.dispose();
  }

  // string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final FirebaseAuthService firebaseAuthService = FirebaseAuthService();
    return Scaffold(
      body: displayGroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: ((context, setState) {
                  return AlertDialog(
                    title: Text("Group Name:"),
                    content: TextFormField(
                      controller: groupNameTextController,
                      onChanged: (value) {
                        groupName = value;
                        selectedPrivacyOption = value!;
                      },
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.purple), // Set background color to purple
                          ),
                          child: Text("CANCEL",
                              style: TextStyle(color: Colors.white))
                      ),

                      DropdownMenu<String>(
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              // User chooses this for privacy section
                              selectedPrivacyOption = value!;
                            });
                          },
                        dropdownMenuEntries: privacyList.map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(value: value, label: value);
                        }).toList(),
                      ),

                      ElevatedButton(
                          onPressed: () async {
                            if (groupName != "") {
                              // Call createGroup method from DatabaseService
                              await DatabaseService(
                                  uid: FirebaseAuth
                                      .instance.currentUser!.uid)
                                  .createGroup(
                                  userName,
                                  FirebaseAuth.instance.currentUser!.uid,
                                  groupName,
                                selectedPrivacyOption
                              );
                              Navigator.of(context).pop();
                            }
                            groupNameTextController.clear();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.purple), // Set background color to purple
                          ),
                          child: Text("CREATE GROUP",
                              style: TextStyle(color: Colors.white)))
                    ],
                  );
                }));
              });
        },
        tooltip: 'Create New Group',
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  displayGroupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  // int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupCard(
                    // groupId: getId(snapshot.data['groups'][reverseIndex]),
                    // groupName: getName(snapshot.data['groups'][reverseIndex]),
                      groupId: snapshot.data['groups'][index].substring(0, snapshot.data['groups'][index].indexOf("_")),
                      groupName: snapshot.data['groups'][index].substring(snapshot.data['groups'][index].indexOf("_") + 1),
                      userName: snapshot.data['displayName'],
                  );
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 50,
                      color: Colors.purple, // You can change the color of the icon
                    ),
                    SizedBox(height: 10), // Add spacing between icon and text
                    Text(
                      'Create A Group!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }
          }
          else {
            return Text("No groups!");
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Colors.deepPurple),
          );
        }
      },
    );
  }
}


class FindGroups extends StatefulWidget {
  const FindGroups({super.key});

  @override
  State<FindGroups> createState() => _FindGroupsState();
}

class _FindGroupsState extends State<FindGroups> {
  var searchName = "";

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
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              filled: true,
              fillColor: Colors.grey.shade200,
              hintText: 'Search Groups',
              hintStyle: TextStyle(color: Colors.grey.shade800),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("groups").where("privacySetting", isEqualTo: "Public").orderBy('groupName').startAt([searchName]).endAt([searchName + "\uf8ff"]).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Text("Something went wrong with search");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Groups Found'),
            );
          }

          // get list of membersID
          // if thisUSERID is in membersList, then mark that as JOINED!
          // else, add to group!


          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
              List<dynamic> membersList = data['members'];
              bool isUserIDFound = membersList.contains(currentUserId);
              return ListTile(
                onTap: () {
                },
                leading: Icon(
                  Icons.group,
                  color: Colors.deepPurple,
                  // backgroundImage: NetworkImage(data['photoUrl']),
                ),
                title: Text(data['groupName']),
                //subtitle: Text(data['description']),
                trailing: isUserIDFound ?  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // remove member
                        String? memberID = FirebaseAuth.instance.currentUser?.uid;
                        String? groupID = data['groupId'];
                        String? groupName = data['groupName'];
                        DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(memberID);
                        DocumentReference groupsDocRef = FirebaseFirestore.instance.collection('groups').doc(groupID);
                        FirebaseFirestore.instance.runTransaction((transaction) async {
                          // Access group list FROM user
                          DocumentSnapshot userDoc = await transaction.get(userDocRef);
                          List<String> groupList = List.from(userDoc['groups'] ?? []);

                          // Access members list FROM groups
                          DocumentSnapshot groupsDoc = await transaction.get(groupsDocRef);
                          List<String> membersList = List.from(groupsDoc['members'] ?? []);

                          String? finalGroupName = groupID! + "_" + groupName!;
                          // NOTE: groupName is in the form of: groupID + "_" + groupName
                          if (groupList.contains(finalGroupName)) {
                            // REMOVE group from user
                            groupList.remove(finalGroupName);
                            transaction.update(userDocRef, {'groups': groupList});
                          }

                          if (membersList.contains(memberID)){
                            // REMOVE user as a member FROM the group
                            membersList.remove(memberID);
                            transaction.update(groupsDocRef, {'members': membersList});
                          }
                        });

                      });
                    },
                    child: Text("JOINED")
                ) : ElevatedButton(

                    onPressed: () {
                      setState(() {
                        // Add member

                        String? memberID = FirebaseAuth.instance.currentUser?.uid;
                        String? groupID = data['groupId'];
                        String? groupName = data['groupName'];
                        DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(memberID);
                        DocumentReference groupsDocRef = FirebaseFirestore.instance.collection('groups').doc(groupID);
                        FirebaseFirestore.instance.runTransaction((transaction) async {
                          // Access group list FROM user
                          DocumentSnapshot userDoc = await transaction.get(userDocRef);
                          List<String> groupList = List.from(userDoc['groups'] ?? []);

                          // Access members list FROM groups
                          DocumentSnapshot groupsDoc = await transaction.get(groupsDocRef);
                          List<String> membersList = List.from(groupsDoc['members'] ?? []);

                          String? finalGroupName = groupID! + "_" + groupName!;
                          // NOTE: groupName is in the form of: groupID + "_" + groupName
                          if (!groupList.contains(finalGroupName)) {
                            // ADD group from user
                            groupList.add(finalGroupName);
                            transaction.update(userDocRef, {'groups': groupList});
                          }

                          if (!membersList.contains(memberID)){
                            // ADD user as a member FROM the group
                            membersList.add(memberID!);
                            transaction.update(groupsDocRef, {'members': membersList});
                          }
                        });

                      });
                    },
                    child: Text("   JOIN  ")
                ),



              );
            },
          );
        },
      ),
    );
  }
}
