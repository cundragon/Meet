import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MembersScreen extends StatefulWidget {
  final List<String> peopleEmail;
  final String eventTitle;

  MembersScreen({
    required this.peopleEmail,
    required this.eventTitle,
  });

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<String> selectedMembers = [];
  List<String> remainingMembers = [];
  String? currentUserEmail = "meomeo";
  String? hostEmail;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await _getCurrentUserEmail();
    _getRemainingMembers();
    _getHostEmail();
    print('$currentUserEmail');
  }

  Future<void> _getCurrentUserEmail() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserEmail = user.email!;
      });
    }
  }

  Future<void> _getRemainingMembers() async {
    List<String> allUsers = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('Users').get();

      for (var doc in snapshot.docs) {
        allUsers.add(doc['email']);
      }

      setState(() {
        remainingMembers =
            allUsers.where((user) => !widget.peopleEmail.contains(user)).toList();
      });
    } catch (e) {
      print("Error getting remaining members: $e");
      throw Exception("Failed to get remaining members");
    }
  }

  void _displayAlertDialog(BuildContext context, List<String> members) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Members'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: remainingMembers
                      .map((item) => CheckboxListTile(
                    value: selectedMembers.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      setState(() {
                        if (isChecked != null) {
                          if (isChecked) {
                            selectedMembers.add(item);
                          } else {
                            selectedMembers.remove(item);
                          }
                        }
                      });
                    },
                  ))
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateEventPeople(selectedMembers);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateEventPeople(List<String> selectedMembers) async {
    try {
      CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('Events');

      QuerySnapshot<Object?> snapshot = await eventsCollection
          .where('Title', isEqualTo: widget.eventTitle)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String eventId = snapshot.docs.first.id;

        await eventsCollection.doc(eventId).update({
          'People': FieldValue.arrayUnion(selectedMembers),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event updated with new members'),
          ),
        );

        print('Event updated with new members: $selectedMembers');
        setState(() {
          widget.peopleEmail.addAll(selectedMembers);
        });
      } else {
        print('Event not found');
      }
    } catch (e) {
      print('Failed to update event: $e');
    }
  }

  void _getHostEmail() {
    FirebaseFirestore.instance
        .collection('Events')
        .where('Title', isEqualTo: widget.eventTitle)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        setState(() {
          hostEmail = doc['Host'];
        });
      } else {
        print('Event not found');
      }
    }).catchError((error) {
      print("Failed to get event: $error");
    });
  }



  void _showMemberOptions(String userEmail, String? currentUserEmail, String? selectedAction) {
    FirebaseFirestore.instance
        .collection('Events')
        .where('Title', isEqualTo: widget.eventTitle)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        String hostEmail = doc['Host'];

        print('Host Emails: $hostEmail');
        print('User is logging in: $currentUserEmail');

        if (currentUserEmail == hostEmail) {
          if (selectedAction == 'make_co_host') {
            _makeCoHost(userEmail);
          } else if (selectedAction == 'remove') {
            _removeMember(userEmail);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Only the host can make changes.'),
            ),
          );
        }
      } else {
        print('Event not found');
      }
    }).catchError((error) {
      print("Failed to get event: $error");
    });
  }


  void _makeCoHost(String userEmail) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$userEmail is now a Co-Host'),
      ),
    );
  }

  void _removeMember(String userEmail) async {
    try {
      CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('Events');

      QuerySnapshot<Object?> snapshot = await eventsCollection
          .where('Title', isEqualTo: widget.eventTitle)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String eventId = snapshot.docs.first.id;

        await eventsCollection.doc(eventId).update({
          'People': FieldValue.arrayRemove([userEmail]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userEmail removed from the event'),
          ),
        );

        print('$userEmail removed from the event');

        setState(() {
          widget.peopleEmail.remove(userEmail);
        });
      } else {
        print('Event not found');
      }
    } catch (e) {
      print('Failed to remove member: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: Text('Add Members'),
            onTap: () {
              _getRemainingMembers();
              _displayAlertDialog(context, remainingMembers);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.peopleEmail.length,
              itemBuilder: (context, index) {
                String userEmail = widget.peopleEmail[index];
                bool isHost = userEmail == hostEmail;
                return ListTile(
                  title: FutureBuilder<DocumentSnapshot>(
                    future: _getUserData(widget.peopleEmail[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      } else if (snapshot.hasError) {
                        return Text('Error');
                      } else {
                        DocumentSnapshot<Map<String, dynamic>>? userSnapshot =
                        snapshot.data as DocumentSnapshot<Map<String, dynamic>>?;
                        if (userSnapshot == null || !userSnapshot.exists) {
                          return Text('User not found');
                        }
                        var userData = userSnapshot.data()!;
                        String userEmail = userData['email'] ?? 'No Email';
                        String photoUrl = userData['photourl'] ?? '';

                        String displayEmail = isHost
                            ? '$userEmail (Host)'
                            : userEmail;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                            child: photoUrl.isEmpty ? Icon(Icons.person) : null,
                          ),
                          title: Text(displayEmail),
                          subtitle: Text(userData['displayName'] ?? 'No Display Name'),
                          onTap: () {
                            setState(() {
                              if (selectedMembers.contains(userEmail)) {
                                selectedMembers.remove(userEmail);
                              } else {
                                selectedMembers.add(userEmail);
                              }
                            });
                          },
                          selected: selectedMembers.contains(userEmail),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text('Make Co-Host'),
                                value: 'make_co_host',
                              ),
                              PopupMenuItem(
                                child: Text('Remove'),
                                value: 'remove',
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'make_co_host' || value == 'remove') {
                                _showMemberOptions(userEmail,currentUserEmail,value);
                              }
                            },
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData(
      String peopleEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .where('email', isEqualTo: peopleEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        throw Exception('User not found with Email: $peopleEmail');
      }
    } catch (e) {
      print("Error getting user data: $e");
      throw Exception("Failed to get user data");
    }
  }
}
