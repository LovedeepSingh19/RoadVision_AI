import 'package:blackcoffer_video/Screens/VerificationPage.dart';
import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:blackcoffer_video/fields.dart/phone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

final TextEditingController _phoneController = TextEditingController();
double _elementsOpacity = 1;

Future registerUser(String mobile, BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  print(mobile);

  _auth.verifyPhoneNumber(
      phoneNumber: mobile,
      timeout: Duration(seconds: 5),
      verificationCompleted: (AuthCredential authCredential) {
        _auth.signInWithCredential(authCredential).then((result) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => WelcomePage()));
        });
      },
      verificationFailed: (authException) {
        print(authException.message);
      },
      codeSent: (String verificationId, int) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerificationPage(
                      verificationKey: verificationId,
                      phoneController: _phoneController,
                    )));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationId = verificationId;
        print(verificationId);
        print("Timout");
      });
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 160,
        ),
        const Center(
          child: Image(
            image: AssetImage('images/Blackcoffer-logo-new.png'),
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 100, right: 100, top: 70, bottom: 40),
          child: phoneField(
            phoneController: _phoneController,
            fadephone: _elementsOpacity == 0,
          ),
        ),
        ElevatedButton(
            onPressed: () {
              registerUser(_phoneController.text, context);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => VerificationPage(
              //               verificationKey: '',
              //               phoneController: _phoneController,
              //             )));
            },
            child: Container(
              child: const Text("Next"),
            ))
      ],
    ));
  }
}
