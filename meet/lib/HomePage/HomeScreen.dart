import 'package:flutter/material.dart';
import 'package:meet/Chat/MessagesLandingPage.dart';
import 'package:meet/EventCreation/CreateEvent.dart';
import '../Account/profile.dart';
import '../Account/search.dart';
import '../EventDetails/EventDetails.dart';
import '../HomePage/DrawerMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late DateTime selectedDay;
  late List<CleanCalendarEvent> selectedEvent;
  Map<DateTime, List<CleanCalendarEvent>> events = {};
  Map<CleanCalendarEvent, List<String>> eventPeople = {};
  double? longitude;
  double? latitude;
  String? userEmail = "meomeo";
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, String> eventPrivacyLabels = {};


  @override
  void initState() {
    super.initState();
    selectedDay = DateTime.now();
    selectedEvent = events[selectedDay] ?? [];
    _fetchEventsFromFirebase();
    _handleData(selectedDay);
    _getUserInfo();
    print('$userEmail');
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  Map<String, Map<String, double>> eventLocationMap = {};

  Future<void> _fetchEventsFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('Events').get();

      Map<DateTime, List<CleanCalendarEvent>> newEvents = {};
      Map<CleanCalendarEvent, List<String>> newEventPeople = {};

      snapshot.docs.forEach((doc) {
        var data = doc.data();

        if (data.containsKey('Title') &&
            data.containsKey('Start date') &&
            data.containsKey('Description') &&
            data.containsKey('End date') &&
            data.containsKey('People') &&
            data.containsKey('Longitude') &&
            data.containsKey('Latitude') &&
            data.containsKey('Public')) {
          var title = data['Title'];
          var date = data['Start date'];
          var description = "{${doc.id}} ${data['Description']}";
          var endDate = data['End date'];
          List<dynamic> people = data['People'];
          double longitude = data['Longitude'];
          double latitude = data['Latitude'];
          bool isPublic = data['Public'];

          if (date is Timestamp &&
              endDate is Timestamp &&
              (isPublic || people.contains(userEmail))) {
            var eventDate = (date as Timestamp).toDate();
            var endTime = (endDate as Timestamp).toDate();

            var event = CleanCalendarEvent(
              title ?? '',
              startTime: eventDate,
              endTime: endTime,
              description: description ?? '',
              color: Colors.deepPurple,
            );

            String privacyLabel = isPublic ? 'Public' : 'Private';

            DateTime eventDay =
            DateTime(eventDate.year, eventDate.month, eventDate.day);

            if (newEvents.containsKey(eventDay)) {
              newEvents[eventDay]!.add(event);
            } else {
              newEvents[eventDay] = [event];
            }

            newEventPeople[event] = List<String>.from(people);

            eventLocationMap[event.summary] = {
              'Longitude': longitude,
              'Latitude': latitude,
            };

            eventPrivacyLabels[event.summary] = privacyLabel;


          }
        }
      });

      setState(() {
        events = newEvents;
        selectedEvent = events[selectedDay] ?? [];
        eventPeople = newEventPeople;
      });

      print("Events fetched successfully: ${events.length} events");
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  CleanCalendarEvent _createEvent(String title, DateTime startTime,
      DateTime endTime, [String description = '', location = '']) {
    return CleanCalendarEvent(
      title,
      startTime: startTime,
      endTime: endTime,
      description: description,
      location: location,
      color: Colors.deepPurple,
    );
  }

  void _handleData(DateTime date) {
    setState(() {
      selectedDay = DateTime(date.year, date.month, date.day);
      selectedEvent = events.entries
          .where((entry) =>
      entry.key.year == selectedDay.year &&
          entry.key.month == selectedDay.month &&
          entry.key.day == selectedDay.day)
          .expand((entry) => entry.value)
          .toList();
    });
  }

  void _navigateToEventCreationPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventCreation(),
      ),
    );

    if (result != null && result is CleanCalendarEvent) {
      setState(() {
        events[selectedDay] = [...(events[selectedDay] ?? []), result];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Number of events: ${selectedEvent.length}");
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: Colors.deepPurple,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.messenger),
            icon: Icon(Icons.messenger_outline),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add events',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    DateTime defaultSelectedDay = _selectedDay ?? DateTime.now();
    switch (_selectedIndex) {
      case 0:
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Container(
                  height: 400,
                  child: _buildTableCalendar(),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                child: Divider(
                  thickness: 0.5,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // Clock Widget
                    ClockWidget(selectedDay: defaultSelectedDay),
                    // ListView for Events
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedEvent.isEmpty ? 1 : selectedEvent.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (selectedEvent.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 100.0),
                              child: Center(
                                child: Text(
                                  'No upcoming events',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final event = selectedEvent[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                              child: _buildEventContainer(event),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 1:
        return MessagesLandingPage();
      case 2:
        return EventCreation();
      case 3:
        return SearchView();
      case 4:
        return profile();
      default:
        return Center(child: Text('Select a Page'));
    }
  }


  Widget _buildTableCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _handleData(selectedDay);
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) {
        return events[day] ?? [];
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.indigo,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurple,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: Colors.white),
        selectedTextStyle: TextStyle(color: Colors.white),

      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 25,
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Widget _buildEventContainer(CleanCalendarEvent event) {
    String startTimeSuffix = event.startTime.hour < 12 ? 'AM' : 'PM';
    String endTimeSuffix = event.endTime.hour < 12 ? 'AM' : 'PM';

    List<Color> eventColors = [
      Colors.green,
      Colors.blue,
      Colors.yellow.shade800,
      Colors.pink.shade400,
      Colors.purple.shade100,
    ];

    int colorIndex = selectedEvent.indexOf(event) % eventColors.length;

    String privacyLabel = eventPrivacyLabels[event.summary] ?? 'Unknown';

    return GestureDetector(
      onTap: () {
        _navigateToEventDetailPage(event);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        padding: EdgeInsets.all(15.0),
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: eventColors[colorIndex],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.summary,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  //SizedBox(height: 5),
                  Divider(
                    thickness: 2,
                    color: Colors.white,
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 18),
                      SizedBox(width: 5),
                      Text(
                        '${event.startTime.hour % 12}:${event.startTime.minute.toString().padLeft(2, '0')} $startTimeSuffix - ${event.endTime.hour % 12}:${event.endTime.minute.toString().padLeft(2, '0')} $endTimeSuffix',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Text(
              privacyLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToEventDetailPage(CleanCalendarEvent event) {
    String? eventId;

    eventLocationMap.forEach((summary, locationData) {
      if (event.summary == summary) {
        eventId = summary;
      }
    });

    if (eventId != null) {
      longitude = eventLocationMap[eventId!]?['Longitude'];
      latitude = eventLocationMap[eventId!]?['Latitude'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(
            event: event,
            selectedDate: selectedDay,
            eventPeople: eventPeople,
            longitude: longitude ?? 0.0,
            latitude: latitude ?? 0.0,
          ),
        ),
      );
    } else {
      print("Event ID not found for event: ${event.summary}");
    }
  }
}

class ClockWidget extends StatelessWidget {
  final DateTime selectedDay;

  ClockWidget({required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    String formattedDay = DateFormat.d().format(selectedDay);

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Icon(
            Icons.calendar_today,
            size: 55.0,
            color: Colors.deepPurple,
          ),
          Positioned(
            top: 20.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Text(
                formattedDay,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
