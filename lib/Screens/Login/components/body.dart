import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/Login/components/background.dart';
import 'package:flutter_application_1/Screens/Login/login_screen.dart';
import 'package:flutter_application_1/Screens/Signup/signup_screen.dart';
import 'package:flutter_application_1/Services/authentication_services.dart';
import 'package:flutter_application_1/components/already_have_an_account_acheck.dart';
import 'package:flutter_application_1/components/rounded_button.dart';
import 'package:flutter_application_1/components/rounded_input_field.dart';
import 'package:flutter_application_1/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/Screens/HomePage.dart';

class Body extends StatefulWidget {
  const Body({
    Key key,
  }) : super(key: key);
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final AuthenticationServices _auth = AuthenticationServices();
  String emailError = "";

  String passwordError = "";
  String finalError = "";
  String email = "";
  String pin = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              emailController: _emailController,
              hintText: "Your Email",
              onChanged: (value) {
                setState(() {
                  if (value.trim().isEmpty) {
                    emailError = "Please enter Email first";
                  } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    emailError = 'Please enter a valid email address';
                  } else {
                    emailError = "";
                    email = value;
                    debugPrint(value);
                  }
                });
              },
            ),
            Text(
              emailError,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            RoundedPasswordField(
              passwordController: _passwordController,
              onChanged: (value) {
                setState(() {
                  if (value.trim().isEmpty) {
                    passwordError = "Please enter PIN";
                  } else if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                    passwordError = "Please enter a 6 digit PIN";
                  } else {
                    passwordError = "";
                    pin = value;
                    debugPrint(value);
                  }
                });
              },
            ),
            Text(
              passwordError,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            RoundedButton(
              text: "LOGIN",
              press: () async {
                if (emailError == "" && passwordError == "") {
                  bool result = await LoginUser();
                  if (result == true) {
                    Navigator.of(context).pushNamedAndRemoveUntil("homescreen", (Route <dynamic> route) => false);
                  } else if (result == false) {
                    setState(() {
                      finalError = "Invalid Credentials";
                      _emailController.clear();
                      _passwordController.clear();
                    });
                  }
                }
              },
            ),
            Text(
              finalError,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            /*RoundedButton(
              text: "Signout",
              press: () {
                logOut();
              },
            ),*/
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> LoginUser() async {
    dynamic authResult = await _auth.loginUser(email, pin);
    
    if (authResult == null) {
      return false;
    } else {
      return true;
    }
  }

  
}
