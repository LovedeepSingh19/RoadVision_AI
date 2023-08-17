import 'package:blackcoffer_video/Screens/Homepage.dart';
import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: user != null ? WelcomePage() : HomePage());
  }
}

class MyHomePage extends StatelessWidget {
  final user = FirebaseAuth
      .instance.currentUser; // Change this to true to see the WelcomePage

  @override
  Widget build(BuildContext context) {
    return user != null ? WelcomePage() : HomePage();
  }
}
