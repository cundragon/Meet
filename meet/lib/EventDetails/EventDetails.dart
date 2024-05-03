import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../EventDetails/members.dart';
import 'EventAgenda.dart';
import 'maps.dart';


class EventDetailScreen extends StatelessWidget {
  final CleanCalendarEvent event;
  final DateTime selectedDate;
  final Map<CleanCalendarEvent, List<String>> eventPeople;
  final double longitude;
  final double latitude;

  const EventDetailScreen({
    Key? key,
    required this.event,
    required this.selectedDate,
    required this.eventPeople,
    required this.longitude,
    required this.latitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> peopleEmail = eventPeople[event] ?? [];
    String text = event.description;
    List<String> parts = text.split(' ');

    // Extract the id by removing the curly braces
    String id = parts[0].substring(1, parts[0].length - 1);

    // Join the remaining parts to form the description
    String description = parts.sublist(1).join(' ');


    print("People Emails for Event: $peopleEmail");

    print("Longitude received: $longitude");
    print("Latitude received: $latitude");



    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(event.summary, style: TextStyle(fontSize: 25, color: Colors.black)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                'https://media.istockphoto.com/id/1308949444/vector/business-meeting-illustration.jpg?s=612x612&w=0&k=20&c=3fEk-l6DdPP9ivUj59zHEb8Um-Hv85Zt-ExSz546DAo=',
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.0),

            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(0.0),
                height: MediaQuery.of(context).size.width * .11,
                width: MediaQuery.of(context).size.width * .6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: <Widget>[
                    LayoutBuilder(builder: (context, constraints) {
                      print(constraints);
                      return Container(
                        height: constraints.maxHeight,
                        width: constraints.maxHeight,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.date_range,
                          color: Colors.white,
                        ),
                      );
                    }),
                    Expanded(
                      child: Text(
                        '${_formatDate(selectedDate)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * .05,
            ),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(0.0),
                height: MediaQuery.of(context).size.width * .11,
                width: MediaQuery.of(context).size.width * .6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: <Widget>[
                    LayoutBuilder(builder: (context, constraints) {
                      print(constraints);
                      return Container(
                        height: constraints.maxHeight,
                        width: constraints.maxHeight,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: Colors.white,
                        ),
                      );
                    }),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          '${_formattedTime(event.startTime)} - ${_formattedTime(event.endTime)}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * .05,),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapScreen(lat: latitude ,long: longitude)),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(0.0),
                  height: MediaQuery.of(context).size.width * .11,
                  width: MediaQuery.of(context).size.width * .6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      LayoutBuilder(builder: (context, constraints) {
                        print(constraints);
                        return Container(
                          height: constraints.maxHeight,
                          width: constraints.maxHeight,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: Colors.white,
                          ),
                        );
                      }),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Direction to event',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * .05,
            ),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventAgendaPage(eventId: id,event: event),
                  ),
                );},
                child: Container(
                  padding: EdgeInsets.all(0.0),
                  height: MediaQuery.of(context).size.width * .11,
                  width: MediaQuery.of(context).size.width * .6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      LayoutBuilder(builder: (context, constraints) {
                        print(constraints);
                        return Container(
                          height: constraints.maxHeight,
                          width: constraints.maxHeight,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.dns,
                            color: Colors.white,
                          ),
                        );
                      }),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'Event Agenda',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
                'Participants',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 8.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MembersScreen(peopleEmail: peopleEmail, eventTitle: event.summary),
                  ),
                );
              },
              child: _buildPeopleList(peopleEmail),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
  }


  String _formattedTime(DateTime dateTime) {
    String suffix = dateTime.hour < 12 ? 'AM' : 'PM';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    return '${hour}:${dateTime.minute.toString().padLeft(2, '0')} $suffix';
  }


  Widget _buildPeopleList(List<String> peopleEmail) {
    return SizedBox(
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: peopleEmail.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FutureBuilder<DocumentSnapshot>(
              future: _getUserData(peopleEmail[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildAvatarPlaceholder();
                } else if (snapshot.hasError) {
                  return _buildAvatarPlaceholder();
                } else {
                  DocumentSnapshot? userSnapshot = snapshot.data;
                  if (userSnapshot == null || !userSnapshot.exists) {
                    return _buildAvatarPlaceholder();
                  }
                  var userData = userSnapshot.data() as Map<String, dynamic>;
                  String photoUrl = userData['photourl'] ?? '';

                  print('Photo URL for user ${userData['email']}: $photoUrl');

                  return _buildAvatar(photoUrl);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String photoUrl) {
    return CircleAvatar(
      radius: 20.0,
      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
      child: photoUrl.isEmpty
          ? Icon(Icons.person, size: 40.0, color: Colors.grey)
          : null,
    );
  }

  Widget _buildAvatarPlaceholder() {
    return CircleAvatar(
      radius: 20.0,
      child: Icon(Icons.person, size: 40.0, color: Colors.grey),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        throw Exception('User not found with email: $email');
      }
    } catch (e) {
      print("Error getting user data: $e");
      throw Exception("Failed to get user data");
    }
  }

}