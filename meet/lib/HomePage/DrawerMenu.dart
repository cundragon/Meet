import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Account/loginpage.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String? userId = "hello";
  String? userEmail = "hello";
  String? photoURL = "hello";
  void _navigateToScreen(BuildContext context, String option) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return OptionScreen(option);
    }));
  }

  @override
  void initState() {
    super.initState();
    // Retrieve user information when the widget initializes
    _getUserInfo();
    print('$userId');
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.displayName;
        userEmail = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(

              accountName: Text(userId!,
                  style: TextStyle(color: Colors.white, fontSize: 18.0)),
              accountEmail:  Text(userEmail!,
                  style: TextStyle(color: Colors.white, fontSize: 18.0)),
              decoration: BoxDecoration(color: Colors.deepPurple,),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(photoURL!),
                radius: 100,
              ),
            ),

            ListTile(
                iconColor: Colors.black,
                leading: Icon(Icons.logout),
                title: Text('Log Out', style: TextStyle(color: Colors.black, fontSize: 15.0)),
                onTap: () {
                  _signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  LoginPage()),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}

class OptionScreen extends StatelessWidget {
  final String option;

  OptionScreen(this.option);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(option),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          '$option',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}
