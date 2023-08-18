import 'dart:async';
import 'dart:io';

import 'package:blackcoffer_video/Screens/Homepage.dart';
import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:blackcoffer_video/providers/user_provider.dart';
import 'package:blackcoffer_video/utils/user_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  final user = FirebaseAuth.instance.currentUser;

  bool _isButtonDisabled = false;

  void _disableButtonForSeconds(int seconds) {
    setState(() {
      _isButtonDisabled = true;
    });

    Timer(Duration(seconds: seconds), () {
      setState(() {
        _isButtonDisabled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    dynamic _pickImageError;

    @override
    void _showProfileDialog(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return UserDialog();
        },
      );
    }

    Future checkDocumentExists(String uid, context) async {
      try {
        final FirebaseFirestore _firebase = FirebaseFirestore.instance;
        final documentSnapshot = await _firebase
            .collection('users')
            .where('uid', isEqualTo: uid)
            .get();

        if (documentSnapshot.size == 1) {
          print(documentSnapshot.docs.first['name']);
          print(documentSnapshot.docs.first['uid']);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => WelcomePage()));
        } else {
          print('no data in snapshot');
          _showProfileDialog(context);
        }
      } catch (error) {
        print("Error checking document: $error");
        return false;
      }
    }

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
                FirebaseAuth auth = FirebaseAuth.instance;

                final smsCode = _codeController.text.trim();

                final authCred = PhoneAuthProvider.credential(
                    verificationId: widget.verificationKey, smsCode: smsCode);
                auth.signInWithCredential(authCred).then((result) {
                  checkDocumentExists(result.user!.uid, context);
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
