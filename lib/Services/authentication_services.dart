import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future createNewUser(String email, String pin) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: pin);
      User user = result.user;
      return user;
    } catch (e) {
      print(e.message());
    }
  }

  Future loginUser(String email, String pin) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: pin);

      return result.user;
    } catch (e) {
      //print(e.message());
      return null;
    }
  }

  Future logOut() async {
    try {
      return _auth.signOut();
    } catch (e) {
      print(e.message());
      return null;
    }
  }
}
