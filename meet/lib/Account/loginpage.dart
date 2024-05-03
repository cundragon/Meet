
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet/Account/signuppage.dart';

import '../Firebase/firebase_auth_services.dart';
import '../HomePage/HomeScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50,),
                const Text(
                  "Welcome to Meet",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'Open Sans', // Or any other font that fits your app's theme
                    letterSpacing: 1.5,
                    color: Colors.deepPurple, // Adjust based on your app's color scheme
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  "Crafting Perfect Events, One Tap at a Time", // Example slogan
                  textAlign: TextAlign.center, // Centers the slogan, if appropriate for your design
                  style: TextStyle(
                    fontWeight: FontWeight.w500, // Medium
                    fontSize: 18,
                    fontFamily: 'Open Sans',
                    fontStyle: FontStyle.italic, // Adds a touch of elegance
                    letterSpacing: 0.5,
                    color: Colors.deepPurple.shade300, // A softer version of the title's color
                  ),
                ),
                Image.asset(
                  'assets/icon5.png', // Replace with the path to your logo image
                  width: 250, // Adjust the width as needed
                  height: 250, // Adjust the height as needed
                ),

                const SizedBox(height: 0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // You might adjust this if your off-white differs
                      border: Border.all(color: Colors.grey[300]!), // Softer border color
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjusted for icon spacing
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.deepPurple,
                        onSaved: (email) {},
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.deepPurple), // Email icon with deep purple color
                        ),
                      ),
                    ),
                  ),

                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Adjust this if your off-white is different
                      border: Border.all(color: Colors.grey[300]!), // Softer border color
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjusted for icon spacing
                      child: TextFormField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.deepPurple,
                        obscureText: !_passwordVisible, // Controls visibility based on the boolean state
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple), // Lock icon with deep purple color
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Toggle the icon based on password visibility
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              // Update the password visibility state on icon press
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25), // Aligns button with text fields
                  child: Container(
                    height: 60, // Adjust the height to your preference
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _signIn();
                        },
                        child: const Center(
                          child: Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not a member? "),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);


    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully Signed In"),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Incorrect Email/Password"),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}
