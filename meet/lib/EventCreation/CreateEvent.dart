import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meet/HomePage/HomeScreen.dart';
import 'package:meet/EventCreation/SearchPlacesScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteModel {
  String title;
  String description;
  DateTime start_date;
  DateTime end_date;
  List<String> members;
  double lat;
  double long;
  bool public;
  String host;

  NoteModel(
      {required this.title,
      required this.start_date,
      required this.end_date,
      required this.description,
      required this.members,
      required this.lat,
      required this.long,
      required this.host,
      required this.public});

  Map<String, dynamic> toMap() {
    return {
      "Title": title,
      "Description": description,
      "Start date": start_date,
      "End date": end_date,
      "People": members,
      "Latitude": lat,
      "Longitude": long,
      "Host": host,
      "Public": public
    };
  }
}

class EventCreation extends StatefulWidget {
  const EventCreation({Key? key}) : super(key: key);

  @override
  _EventCreationState createState() => _EventCreationState();
}

class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add people to the event'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

const Apikey = 'AIzaSyAScjj76S3sy3HX8KTM7PDwF_Af6BKEZ3M';



class _EventCreationState extends State<EventCreation> {

  User? user = FirebaseAuth.instance.currentUser;

  late TextEditingController eventNameController;
  late TextEditingController eventNameController2;

  List<String> members = [];
  String title1 = '';
  String description = '';
  bool checkBoxValue = false;
  List<String> selected_mem = [];

  Future<DateTime?> pickDateTime() async {
    final date = await pickDate();
    if (date == null) return null;

    final time = await pickTime();
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<DateTime?> pickDate() async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(initialDate.year - 5),
      lastDate: DateTime(initialDate.year + 5),
    );

    if (newDate == null) return null;

    return newDate;
  }

  Future<TimeOfDay?> pickTime() async {
    final initialTime = TimeOfDay.fromDateTime(DateTime.now());
    final newTime = await showTimePicker(
      context: context,
      initialTime: dateTime != null
          ? TimeOfDay(hour: dateTime.hour, minute: dateTime.minute)
          : initialTime,
    );

    if (newTime == null) return null;

    return newTime;
  }



  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController();
  }

  @override
  void dispose() {
    eventNameController.dispose();

    super.dispose();
  }

  DateTime dateTime = DateTime.now();
  DateTime endTime = DateTime.now();

  Future<void> _buildl(members1) async {
    CollectionReference usersCollection = firestore.collection('Users');

    QuerySnapshot usersSnapshot = await usersCollection.get();

    for (var user1 in usersSnapshot.docs) {
      if (!members1.contains(user1['email'])) {
        if(user!.email as String != user1['email']) {
          members1.add(user1['email']);
        }
      }

    }
  }

  void _showMultiSelect(List<String> items) async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: items);
      },
    );
    if (results != null) {
      setState(() {
        selected_mem = results;
      });
    }
  }

  void _display(a) {
    _showMultiSelect(a);
  }



  @override
  Widget build(BuildContext context) {
    Future<DateTime?> pickDate() => showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime(2024),
          lastDate: DateTime(2200),
        );

    Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));

    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("Event Creation", style: TextStyle(fontSize: 35, color: Colors.black, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: eventNameController,
                  onChanged: (text) {
                    title1 = text;
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter event title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.event),
                  ),
                ),
                Container(
                  height: MediaQuery.sizeOf(context).height * 0.02,
                ),
                TextField(
                  onChanged: (text) {
                    description = text;
                  },
                  autocorrect: true,
                  decoration: InputDecoration(
                      hintText: 'Enter event description',
                      labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.description),
                  ),
                  onSubmitted: (String b) {
                    description = b;
                  },
                ),
                Opacity(
                  opacity: 0,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.02,
                    decoration: BoxDecoration(),
                  ),
                ),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchPlacesScreen()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(0.0),
                      height: MediaQuery.of(context).size.width * .11,
                      width: MediaQuery.of(context).size.width * .38,
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
                                Icons.place,
                                color: Colors.white,
                              ),
                            );
                          }),
                          Expanded(
                            child: Text(
                              'Location',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.02,
                    decoration: BoxDecoration(),
                  ),
                ),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Start Time"),
                          Container(
                            height: MediaQuery.sizeOf(context).width * 0.02,
                            decoration: BoxDecoration(),
                          ),
                          Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () async {
                                final date = await pickDateTime();
                                if (date == null) return;
                                setState(() => dateTime = date);
                              },
                              child: Container(
                                padding: EdgeInsets.all(0.0),
                                height: MediaQuery.of(context).size.width * .11,
                                width: MediaQuery.of(context).size.width * .44,
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
                                          Icons.date_range,
                                          color: Colors.white,
                                        ),
                                      );
                                    }),
                                    Expanded(
                                      child: Text(
                                        '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}',
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
                          ),
                        ],
                      ),
                      Opacity(
                        opacity: 0,
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.03,
                          height: 0,
                          decoration: BoxDecoration(),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("End Time"),
                          Container(
                            height: MediaQuery.sizeOf(context).width * 0.02,
                            decoration: BoxDecoration(),
                          ),
                          Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () async {
                                final date = await pickDateTime();
                                if (date == null) return;
                                setState(() => endTime = date);
                              },
                              child: Container(
                                padding: EdgeInsets.all(0.0),
                                height: MediaQuery.of(context).size.width * .11,
                                width: MediaQuery.of(context).size.width * .44,
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
                                          Icons.date_range,
                                          color: Colors.white,
                                        ),
                                      );
                                    }),
                                    Expanded(
                                      child: Text(
                                        '${endTime.year}/${endTime.month}/${endTime.day} ${endTime.hour}:${endTime.minute}',
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
                          ),

                        ],
                      ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     final date = await pickDateTime();
                      //
                      //     if (date == null) return;
                      //     final updatedtime = DateTime(
                      //       date.year,
                      //       date.month,
                      //       date.day,
                      //       dateTime.hour,
                      //       dateTime.minute,
                      //     );
                      //     setState(() => dateTime = updatedtime);
                      //   },
                      //   child: Text(
                      //       '${dateTime.year}/${dateTime.month}/${dateTime.day}'),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.deepPurple,
                      //     foregroundColor: Colors.black,
                      //   ),
                      // ),
                      // Opacity(
                      //   opacity: 0,
                      //   child: Container(
                      //     width: MediaQuery.sizeOf(context).width * 0.1,
                      //     height: 0,
                      //     decoration: BoxDecoration(),
                      //   ),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     final time = await pickTime();
                      //     if (time == null) return;
                      //     final updatedtime = DateTime(
                      //       dateTime.year,
                      //       dateTime.month,
                      //       dateTime.day,
                      //       time.hour,
                      //       time.minute,
                      //     );
                      //     setState(() => dateTime = updatedtime);
                      //   },
                      //   child: Text('${dateTime.hour}:${dateTime.minute}'),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.deepPurple,
                      //     foregroundColor: Colors.black,
                      //   ),
                      // ),
                    ]),
                // Opacity(
                //   opacity: 0,
                //   child: Container(
                //     width: MediaQuery.sizeOf(context).width,
                //     height: MediaQuery.sizeOf(context).height * 0.032,
                //     decoration: BoxDecoration(),
                //   ),
                // ),
                // Text("End Time"),
                // Row(
                //     mainAxisSize: MainAxisSize.max,
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       ElevatedButton(
                //         onPressed: () async {
                //           final date = await pickDate();
                //
                //           if (date == null) return;
                //           final updatedtime = DateTime(
                //             date.year,
                //             date.month,
                //             date.day,
                //             endTime.hour,
                //             endTime.minute,
                //           );
                //           setState(() => endTime = updatedtime);
                //         },
                //         child: Text(
                //             '${endTime.year}/${endTime.month}/${endTime.day}'),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.deepPurple,
                //           foregroundColor: Colors.black,
                //         ),
                //       ),
                //       Opacity(
                //         opacity: 0,
                //         child: Container(
                //           width: MediaQuery.sizeOf(context).width * 0.1,
                //           height: 0,
                //           decoration: BoxDecoration(),
                //         ),
                //       ),
                //       ElevatedButton(
                //         onPressed: () async {
                //           final time = await pickTime();
                //           if (time == null) return;
                //           final updatedtime = DateTime(
                //             endTime.year,
                //             endTime.month,
                //             endTime.day,
                //             time.hour,
                //             time.minute,
                //           );
                //           setState(() => endTime = updatedtime);
                //         },
                //         child: Text('${endTime.hour}:${endTime.minute}'),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.deepPurple,
                //           foregroundColor: Colors.black,
                //         ),
                //       ),
                //     ]),
                Opacity(
                  opacity: 0,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.01,
                    decoration: BoxDecoration(),
                  ),
                ),

                CheckboxListTile(
                  title: Text("Public"),
                  value: checkBoxValue,
                  onChanged: (newValue) {
                    setState(() {
                      checkBoxValue = newValue!;
                    });
                  },

                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                Opacity(
                  opacity: 0,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.02,
                    decoration: BoxDecoration(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.people), // ListTile Icons
                  title: Text('Add people'),
                  trailing: const Icon(Icons.keyboard_arrow_right),

                  onTap: () async {
                    await _buildl(members);

                    _display(members);
                  },
                  selected: true,
                  enabled: true,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height * 0.05,
                    decoration: BoxDecoration(),
                  ),
                ),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          selected_mem.add(user!.email as String);
                          print(user!.email as String);
                          NoteModel noteToUpdate = NoteModel(
                              title: title1,
                              description: description,
                              start_date: dateTime,
                              end_date: endTime,
                              lat: lat1,
                              long: long1,
                              host: user!.email as String,
                              members: selected_mem,
                              public: checkBoxValue);

                          await firestore.collection("Events").doc().set(
                                noteToUpdate.toMap(),
                                SetOptions(
                                  merge: true,
                                ),
                              );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                        child: Text(
                          'Create Event',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



