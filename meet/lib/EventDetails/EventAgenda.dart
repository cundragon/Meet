import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';



class EventAgendaPage extends StatefulWidget {

  final String eventId;
  final CleanCalendarEvent event;


  EventAgendaPage({required this.eventId, required this.event});
  @override
  _EventAgendaPageState createState() => _EventAgendaPageState();
}

class _EventAgendaPageState extends State<EventAgendaPage> {
  final List<Color> colors = [Colors.pink.shade200, Colors.purple.shade400, Colors.purple.shade900, Colors.grey.shade600, Colors.black];
  List<Map<String, dynamic>> agenda = [
  ];

  @override
  void initState() {
    super.initState();
    _fetchEventsFromFirebase();
  }

  Future<void> _fetchEventsFromFirebase() async {
    try {
      DocumentReference eventDocRef = FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.eventId);


      // Fetch agenda items from the 'Agenda' collection
      QuerySnapshot<Map<String, dynamic>> snapshot = await eventDocRef
          .collection('Agenda')
          .orderBy('time')
          .get();

      List<Map<String, dynamic>> agendaItems = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        agenda = agendaItems.map((item) {
          TimeOfDay time = TimeOfDay(
            hour: int.parse(item['time'].split(':')[0]),
            minute: int.parse(item['time'].split(':')[1]),
          );
          return {'time': time, 'activity': item['activity']};
        }).toList();
      });

      print("Agenda items fetched successfully: ${agenda.length} items");
    } catch (e) {
      print("Error fetching agenda items: $e");
    }
  }


  TextEditingController _activityController = TextEditingController();

  void _addAgendaItem() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      DateTime agendaDateTime = DateTime(
        widget.event.startTime.year,
        widget.event.startTime.month,
        widget.event.startTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (agendaDateTime.isBefore(widget.event.startTime) || agendaDateTime.isAfter(widget.event.endTime)) {
        // Show an error message if the selected time is outside the event's time range
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The selected time is outside the event\'s time range.'),
          ),
        );
        return;
      }
      String formattedTime = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

      await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.eventId)
          .collection('Agenda')
          .add({
        'time': formattedTime,
        'activity': _activityController.text,
      });

      _activityController.clear();
      _fetchEventsFromFirebase();
    }
  }

  void _editAgendaItem(int index) async {
    TextEditingController editActivityController = TextEditingController(text: agenda[index]['activity']);
    String oldActivity = agenda[index]['activity'];
    TimeOfDay? selectedTime = agenda[index]['time'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text('Edit Agenda Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editActivityController,
                decoration: InputDecoration(labelText: 'Activity'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color?>(Colors.deepPurple),
                  elevation: MaterialStateProperty.all<double>(8),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.deepPurpleAccent.withOpacity(0.2);
                      }
                      return null;
                    },
                  ),
                ),
                onPressed: () async {
                  selectedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime!,
                  );
                  if (selectedTime != null) {
                    DateTime agendaDateTime = DateTime(
                      widget.event.startTime.year,
                      widget.event.startTime.month,
                      widget.event.startTime.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );

                    if (agendaDateTime.isBefore(widget.event.startTime) || agendaDateTime.isAfter(widget.event.endTime)) {
                      // Show an error message if the selected time is outside the event's time range
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('The selected time is outside the event\'s time range.'),
                        ),
                      );
                      return;
                    }

                    if (_isOverlapping(selectedTime!, excludeIndex: index)) {
                      _showOverlapNotification();
                    } else {
                      String newActivity = editActivityController.text;
                      String formattedTime = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

                      // Update the agenda item in Firestore
                      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
                          .collection('Events')
                          .doc(widget.eventId)
                          .collection('Agenda')
                          .where('activity', isEqualTo: oldActivity)
                          .get();

                      if (snapshot.docs.isNotEmpty) {
                        await snapshot.docs.first.reference.update({
                          'time': formattedTime,
                          'activity': newActivity,
                        });
                      }

                      // Fetch the updated agenda items from Firestore
                      _fetchEventsFromFirebase();

                      Navigator.pop(context);
                    }
                  }

                },
                child: Text('Select Time', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedTime != null) {
                  DateTime agendaDateTime = DateTime(
                    widget.event.startTime.year,
                    widget.event.startTime.month,
                    widget.event.startTime.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  if (agendaDateTime.isBefore(widget.event.startTime) || agendaDateTime.isAfter(widget.event.endTime)) {
                    // Show an error message if the selected time is outside the event's time range
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('The selected time is outside the event\'s time range.'),
                      ),
                    );
                    return;
                  }

                  if (_isOverlapping(selectedTime!, excludeIndex: index)) {
                    _showOverlapNotification();
                  } else {
                    String newActivity = editActivityController.text;
                    String formattedTime = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

                    // Update the agenda item in Firestore
                    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
                        .collection('Events')
                        .doc(widget.eventId)
                        .collection('Agenda')
                        .where('activity', isEqualTo: oldActivity)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                      await snapshot.docs.first.reference.update({
                        'time': formattedTime,
                        'activity': newActivity,
                      });
                    }

                    // Fetch the updated agenda items from Firestore
                    _fetchEventsFromFirebase();

                    Navigator.pop(context);
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAgendaItem(int index) async {
    String activityToDelete = agenda[index]['activity'];

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('Events')
        .doc(widget.eventId)
        .collection('Agenda')
        .where('activity', isEqualTo: activityToDelete)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
      _fetchEventsFromFirebase();
    }
  }

  bool _isOverlapping(TimeOfDay time, {int? excludeIndex}) {
    for (int i = 0; i < agenda.length; i++) {
      if (excludeIndex != null && i == excludeIndex) continue;
      if (agenda[i]['time'] == time) {
        return true;
      }
    }
    return false;
  }

  void _showOverlapNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('The selected time overlaps with another agenda item.'),
      ),
    );
  }

  void _sortAgenda() {
    agenda.sort((a, b) => a['time'].toString().compareTo(b['time'].toString()));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Event Agenda'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: agenda.length,
              itemBuilder: (context, index) {
                final previousTime = index > 0 ? agenda[index - 1]['time'] : null;
                final currentTime = agenda[index]['time'];
                final color = colors[index % colors.length];
                final nextColor = index < agenda.length - 1
                    ? colors[(index + 1) % colors.length]
                    : Colors.transparent;

                return CurvedListItem(
                  title: agenda[index]['activity'],
                  time: _formatTimeOfDay(currentTime),
                  color: color,
                  nextColor: nextColor,
                  onDelete: () => _deleteAgendaItem(index),
                  onEdit: () => _editAgendaItem(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? newActivity = await showGeneralDialog(
            context: context,
            transitionDuration: Duration(milliseconds: 300),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
            pageBuilder: (context, animation, secondaryAnimation) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: Text(
                  'Add Agenda Item',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                content: TextField(
                  controller: _activityController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _activityController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          if (newActivity != null && newActivity.isNotEmpty) {
            _activityController.text = newActivity;
            _addAgendaItem();
          }
        },
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.white,
      ),
    );
  }

}

class CurvedListItem extends StatelessWidget {
  CurvedListItem({super.key,
    required this.title,
    this.time,
    required this.color,
    this.nextColor = Colors.transparent,
    required this.onDelete,
    required this.onEdit,
  });

  final String title;
  final String? time;
  final Color color;
  final Color nextColor;

  final VoidCallback onDelete;
  final VoidCallback onEdit; // Update the onEdit callback to take no arguments

  final List<Color> colors = [
    Colors.pink.shade200,
    Colors.purple.shade400,
    Colors.purple.shade900,
    Colors.grey.shade600,
    Colors.black,
  ];

  final List<Color> iconColors = [
    Colors.pink.shade100,
    Colors.purple.shade300,
    Colors.purple.shade800,
    Colors.grey.shade500,
    Colors.grey.shade900,
  ];

  @override
  Widget build(BuildContext context) {
    int colorIndex = colors.indexOf(color);
    Color iconColor = iconColors[colorIndex];
    return Container(
      color: nextColor,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(80.0),
          ),
        ),
        padding: const EdgeInsets.only(
          left: 32,
          top: 50,
          bottom: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    time!,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),

                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white60,),
                        onPressed: onDelete, // Use the onDelete callback directly
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white60,),
                        onPressed: onEdit, // Use the onEdit callback directly
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                  Icons.event,
                  size: 80,
                  color: iconColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}