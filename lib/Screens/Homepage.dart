import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:blackcoffer_video/fields.dart/phone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

double _elementsOpacity = 1;

class _HomePageState extends State<HomePage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  Future registerUser(String mobile, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    print(mobile);

    _auth.verifyPhoneNumber(
        phoneNumber: mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          _auth.signInWithCredential(authCredential).then((result) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => WelcomePage()));
          });
        },
        verificationFailed: (authException) {
          print(authException.message);
        },
        codeSent: (String verificationId, int) {
          //show dialog to take input from the user
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text("Done"),
                        onPressed: () {
                          FirebaseAuth auth = FirebaseAuth.instance;

                          final smsCode = _codeController.text.trim();

                          final authCred = PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: smsCode);
                          auth.signInWithCredential(authCred).then((result) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WelcomePage()));
                          }).catchError((e) {
                            print(e);
                          });
                        },
                      )
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timout");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(
          height: 150,
        ),
        const Center(
          child: Image(
            image: AssetImage('images/Blackcoffer-logo-new.png'),
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(100),
          child: phoneField(
            phoneController: _phoneController,
            fadephone: _elementsOpacity == 0,
          ),
        ),
        ElevatedButton(
            onPressed: () {
              registerUser(_phoneController.text, context);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => WelcomePage()));
            },
            child: Container(
              child: Text("Submit"),
            ))
      ],
    ));
  }
}
