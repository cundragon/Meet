import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet/Chat/DatabaseService.dart';


Future<Map<String, dynamic>?> fetchMemberData(String userId) async {
  try {
    // Reference to Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the user's document in the 'users' collection
    DocumentReference userDoc = firestore.collection('Users').doc(userId);

    // Fetch the document
    DocumentSnapshot userSnapshot = await userDoc.get();

    // Check if the document exists
    if (userSnapshot.exists) {
      // Return the data as a Map
      return userSnapshot.data() as Map<String, dynamic>?;
    } else {
      // Handle the case where the user does not exist in Firestore
      print('User not found in Firestore');
      return null;
    }
  } catch (e) {
    // Handle any errors
    print('Error fetching user data: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchUserData(String userId) async {
  try {
    // Reference to Firestore
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the user's document in the 'users' collection
    DocumentReference userDoc = firestore.collection('Users').doc(userId);

    // Fetch the document
    DocumentSnapshot userSnapshot = await userDoc.get();

    // Check if the document exists
    if (userSnapshot.exists) {
      // Return the data as a Map
      return userSnapshot.data() as Map<String, dynamic>?;
    } else {
      // Handle the case where the user does not exist in Firestore
      print('User not found in Firestore');
      return null;
    }
  } catch (e) {
    // Handle any errors
    print('Error fetching user data: $e');
    return null;
  }
}

class UserDetailWidget extends StatelessWidget {
  final String userId;
  UserDetailWidget({Key? key, required this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // Display the user data
            return Column(
              children: [
                Text('Admin: ${snapshot.data!['displayName']}'),
              ],
            );
          } else {
            return Text('User data not found');
          }
        } else {
          // Show a loading spinner while waiting for the data
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const GroupInfo(
      {super.key,
      required this.groupName,
      required this.groupId,
      required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  bool isAdmin = false;

  @override
  void initState() {
    getGroupMembers();
    isUserAdmin();
    super.initState();
  }

  getGroupMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  // Function to know if current user is admin or not
  isUserAdmin() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      DocumentSnapshot groupDocSnapshot = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();

      if (userDocSnapshot.exists) {
        if (groupDocSnapshot.exists) {
          String adminID = groupDocSnapshot['admin'];
          if (adminID == userId){
            setState(() {
              isAdmin = true;
            });
          }
        }
      }
    }
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  void removeMember(String memberID) async{
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(memberID);
    DocumentReference groupsDocRef = FirebaseFirestore.instance.collection('groups').doc(widget.groupId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Access group list FROM user
      DocumentSnapshot userDoc = await transaction.get(userDocRef);
      List<String> groupList = List.from(userDoc['groups'] ?? []);

      // Access members list FROM groups
      DocumentSnapshot groupsDoc = await transaction.get(groupsDocRef);
      List<String> membersList = List.from(groupsDoc['members'] ?? []);

      String groupName = widget.groupId + "_" + widget.groupName;
      // NOTE: groupName is in the form of: groupID + "_" + groupName
      if (groupList.contains(groupName)) {
        // REMOVE group from user
        groupList.remove(groupName);
        transaction.update(userDocRef, {'groups': groupList});
      }

      if (membersList.contains(memberID)){
        // REMOVE user as a member FROM the group
        membersList.remove(memberID);
        transaction.update(groupsDocRef, {'members': membersList});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(
          title: Text("Group Information", textAlign: TextAlign.center),

          actions: isAdmin
              ? [
            IconButton(
              icon: Icon(Icons.group_add_outlined), // Icon for adding new member
              onPressed: () {
                // TODO: implement adding members to the group chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddGroupMembersScreen(groupId: widget.groupId, groupName: widget.groupName,),
                  ),
                );
              },
            ),
          ]
              : [],

          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      // color: Theme.of(context).primaryColor.withOpacity(0.2)),
                      color: Colors.purple.withOpacity(0.2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          widget.groupName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Group: ${widget.groupName}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          UserDetailWidget(userId: widget.adminName)
                        ],
                      )
                    ],
                  ),
                ),
                memberList(),
              ],
            )
        ),
    );
  }
  memberList() {
    String memberName = "";
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: fetchMemberData(snapshot.data['members'][index]), // Get user's data from Firestore
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            String memberName = snapshot.data!['displayName'].toString();
                            String memberPhotoUrl = snapshot.data!['photourl'].toString();
                            String memberID = snapshot.data!['uid'].toString();
                            return Row(
                              children:[
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.deepPurple,
                                  backgroundImage: NetworkImage(memberPhotoUrl),
                                ),
                                SizedBox(width: 17),
                                Expanded(
                                  child: Text(memberName),
                                ),

                                isAdmin ?
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () {
                                    removeMember(memberID);
                                  },
                                )
                                    : SizedBox() ,
                              ]
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ));
        }
      },
    );
  }
}



// This class will show the members to be added in the group
class AddGroupMembersScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const AddGroupMembersScreen({Key? key, required this.groupId, required this.groupName}) : super(key: key);

  @override
  _AddGroupMembersScreenState createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  late List<String> availableMembers = []; // List to store available members
  late List<String> membersDisplayName = []; // List to store available members
  List<String> selectedMembers = []; // List to store selected members

  // Function to add selected members to the group
  void addMembersToGroup () async {
    try {
      // Update GROUP document in Firestore to add selected members
      FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
        'members': FieldValue.arrayUnion(selectedMembers),
      }).then((_) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Members added to group')));
        Navigator.pop(context);
      }).catchError((error) {
        print('Error adding members to group: $error');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add members')));
      });

      // Update USER document to add the group that they were just added to

      // You want the added users to be updated... SelectedMemberes already have the userIDS!!!!
      //Access each userID from each selectedmembers
      for (int i = 0; i < selectedMembers.length; i++) {
        String? userId = selectedMembers[i];
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        FirebaseFirestore.instance.runTransaction((transaction) async {
          // Access group list FROM user
          DocumentSnapshot userDoc = await transaction.get(userDocRef);
          List<String> groupList = List.from(userDoc['groups'] ?? []);
          String groupName = widget.groupId + "_" + widget.groupName;
          if (!groupList.contains(groupName)) {
            groupList.add(groupName);
            transaction.update(userDocRef, {'groups': groupList});
          }
        });
      }

    } catch (e) {
      print('Error adding members to group: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add members')));
    }
  }

  @override
  void initState() {
    super.initState();
    // Call function to fetch available members
    fetchAvailableMembers();
  }

  // Function to fetch available members
  void fetchAvailableMembers() async {
    try {
      // Fetch all users from Firestore
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('Users').get();
      // Extract user IDs from the snapshot
      List<String> userIds = usersSnapshot.docs.map((doc) => doc.id).toList();

      // Extract user displayNames:
      List<String> displayNames = usersSnapshot.docs.map((doc) => doc['displayName'] as String).toList();


      setState(() {
        availableMembers = userIds;
        membersDisplayName = displayNames;
      });
    } catch (e) {
      print('Error fetching available members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Group Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // Call function to add selected members to the group
              addMembersToGroup();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: availableMembers.length,
        itemBuilder: (context, index) {
          // Display available members with checkboxes
          String memberId = availableMembers[index];
          String userDisplayName = membersDisplayName[index];
          return CheckboxListTile(
            title: Text(userDisplayName),
            value: selectedMembers.contains(memberId),
            onChanged: (bool? value) {
              setState(() {
                if (value!) {
                  selectedMembers.add(memberId);
                } else {
                  selectedMembers.remove(memberId);
                }
              });
            },
          );
        },
      ),
    );
  }
}
