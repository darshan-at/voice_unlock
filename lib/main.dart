import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/HomePage.dart';
import 'package:flutter_application_1/Screens/Signup/signup_screen.dart';
import 'package:flutter_application_1/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

String email="";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final FirebaseAuth result=FirebaseAuth.instance;
    User user=result.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Unlock',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home:(user !=null ? HomePage(): WelcomeScreen()),
      routes:{
        "homescreen":(context)=>HomePage(),
        "welcomescreen":(context)=>WelcomeScreen(),
        "signupscreen":(context)=>SignUpScreen(),
      },
    );
  }
}
