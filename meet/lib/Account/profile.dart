import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet/Account/usercard.dart';
import '../../Firebase/firebase_auth_services.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'loginpage.dart';


class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _displaynameController = TextEditingController();
  String? userId = "hello";
  String? userEmail = "hello";
  String? photoURL = "hello";
  String imageURL = '';
  bool isObscurePassword = true;


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
        photoURL = user.photoURL;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("Profile", style: TextStyle(fontSize: 35, color: Colors.black, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.grey.shade200,
      ),

      body: Container(
        padding: EdgeInsets.only(left: 15, top: 20, right: 15),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {ImagePicker imagepicker = ImagePicker();
        XFile? file = await imagepicker.pickImage(source: ImageSource.gallery);
        print(file?.path);
        // Add to firebase storage
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceChild = referenceRoot.child('avatars');
        // create final reference
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = Random().nextInt(10000);
        final fileName = 'image_${timestamp}_$random.jpg';

        Reference referenceImageToUpload  = referenceChild.child(fileName);
        // upload
        try{
        await referenceImageToUpload.putFile(File(file!.path));
        imageURL = await referenceImageToUpload.getDownloadURL();
        _auth.updatephotourl(imageURL);



        // Update local UI state
        setState(() {
        photoURL = imageURL; // Update the photo URL to reflect in the UI
        });
        } catch(error){

        }


        },
                child: UserCard(
                  backgroundColor: Colors.deepPurple,
                  userName: userId,
                  userProfilePic: NetworkImage(photoURL!),
                  userMoreInfo: Text(
                    userEmail!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _displaynameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.done,
                      cursorColor: Colors.deepPurple,
                      onSaved: (email) {},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Change Your Display Name',
                        prefixIcon: Icon(Icons.cached, color: Colors.deepPurple),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.check, color: Colors.deepPurple),
                          onPressed: () {
                            _save();
                          },

                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        // Insert your logout logic here
                        await FirebaseAuth.instance.signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, left: 24),
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.white,),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "Sign Out",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    String displayName = _displaynameController.text.trim();

    if (displayName.isNotEmpty) {
      await _auth.updateDisplayName(displayName);
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
// Reload the user to refresh profile data

      // Show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }


}
