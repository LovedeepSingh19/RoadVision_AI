import 'package:blackcoffer_video/Screens/Homepage.dart';
import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  final String verificationKey;
  final TextEditingController phoneController;
  VerificationPage(
      {Key? key, required this.verificationKey, required this.phoneController})
      : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

double _elementsOpacity = 1;

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _codeController = TextEditingController();

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
              padding: const EdgeInsets.only(
                  left: 100, right: 100, top: 70, bottom: 40),
              child: TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: "Enter OPT",
                ),
                keyboardType: TextInputType.phone,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Did not get otp, ",
              ),
              GestureDetector(
                onTap: () {
                  registerUser(widget.phoneController.text, context);
                  print('Text clicked');
                },
                child: const Text(
                  'resend?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => WelcomePage()));
                FirebaseAuth auth = FirebaseAuth.instance;

                final smsCode = _codeController.text.trim();

                final authCred = PhoneAuthProvider.credential(
                    verificationId: widget.verificationKey, smsCode: smsCode);
                auth.signInWithCredential(authCred).then((result) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WelcomePage()));
                }).catchError((e) {
                  print(e);
                });
              },
              child: Container(
                child: const Text("Get started"),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        },
        child: Icon(Icons.arrow_back_ios_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
