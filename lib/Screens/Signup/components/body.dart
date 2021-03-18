import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/Login/login_screen.dart';
import 'package:flutter_application_1/Screens/Signup/components/background.dart';
import 'package:flutter_application_1/components/already_have_an_account_acheck.dart';
import 'package:flutter_application_1/components/rounded_button.dart';
import 'package:flutter_application_1/components/rounded_input_field.dart';
import 'package:flutter_application_1/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_application_1/Services/authentication_services.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final AuthenticationServices _auth = AuthenticationServices();
  String emailError = "";
  String passwordError = "";
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
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
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
                    print(value);
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
              text: "SIGNUP",
              press: () async {
                if (emailError == "" && passwordError == "") {
                  bool result = await createUser();
                  if (result == true) {
                    Navigator.of(context).pushNamedAndRemoveUntil("loginscreen", (Route <dynamic> route) => false);
                  }
                }
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
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

  Future<bool> createUser() async {
    dynamic result = await _auth.createNewUser(email, pin);
    //print(result.toString());
    if (result == null) {
      return false;
    } else {
      return true;
    }
  }
}
