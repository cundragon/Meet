import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Chat/DatabaseService.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Obtain current user (that is logged in)
  User? getUserNow() {
    return _auth.currentUser;
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String displayname, String username) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    credential.user?.updateDisplayName(displayname);
    credential.user?.updatePhotoURL(
        "https://firebasestorage.googleapis.com/v0/b/meet-cs442.appspot.com/o/avatars%2F1000000022.jpg?alt=media&token=b0e7f616-0921-43ec-9f83-657c0de9021c");

    // Save user info in another document
    firestore.collection('Users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'email': email,
      'groups':[],
      'displayName': displayname,
      'username': username,
      'photourl': "https://firebasestorage.googleapis.com/v0/b/meet-cs442.appspot.com/o/avatars%2F1000000022.jpg?alt=media&token=b0e7f616-0921-43ec-9f83-657c0de9021c"
    });

    return credential.user;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // // Save user info in another document
      // firestore.collection('Users').doc(credential.user!.uid).set({
      //   'uid': credential.user!.uid,
      //   'email': email,
      //   'displayName': credential.user!.displayName,
      // });

      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        print('Invalid email or password.');
      } else {
        print('An error occurred: ${e.code}');
      }
    }
    return null;
  }

Future<User?> updateDisplayName(String displayname) async {

  try {
    User? user =await _auth.currentUser;
    user?.updateDisplayName(displayname);
    FirebaseFirestore.instance.collection('Users').doc(user?.uid).update({
      'displayName': displayname,
      // Do not store passwords directly; Firebase Authentication handles this securely
    });
    return user;
  } on FirebaseAuthException catch (e) {

    print('An error occurred: ${e.code}');
  }
  return null;

}
// Future<User?> updatepassword(String password) async {
//
//   try {
//     User? user = _auth.currentUser;
//     user?.updatePassword(password);
//     return user;
//   } on FirebaseAuthException catch (e) {
//
//     if (e.code == 'email-already-in-use') {
//       print( 'The email address is already in use.');
//     } else {
//       print('An error occurred: ${e.code}');
//     }
//   }
//   return null;
//
// }
//
// Future<User?> updateemail(String email) async {
//
//   try {
//     User? user = _auth.currentUser;
//     user?.updateEmail(email);
//     FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('userInfo').doc('userDetails').update({
//       'email': email,
//       // Do not store passwords directly; Firebase Authentication handles this securely
//     });
//     return user;
//   } on FirebaseAuthException catch (e) {
//
//     if (e.code == 'email-already-in-use') {
//       print( 'The email address is already in use.');
//     } else {
//       print('An error occurred: ${e.code}');
//     }
//   }
//   return null;
//
// }
//
Future<User?> updatephotourl(String url) async {

  try {
    User? user = _auth.currentUser;
    user?.updatePhotoURL(url);
    FirebaseFirestore.instance.collection('Users').doc(user?.uid).update({
      'photourl': url,
      // Do not store passwords directly; Firebase Authentication handles this securely
    });
    return user;
  } on FirebaseAuthException catch (e) {


      print('An error occurred: ${e.code}');

  }
  return null;

}

//
}
