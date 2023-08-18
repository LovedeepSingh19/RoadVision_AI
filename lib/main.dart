import 'package:blackcoffer_video/Screens/Homepage.dart';
import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:blackcoffer_video/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => userProvider(),
    ),
  ], child: const MyApp()));
}

Future fetchDocument(String uid, context) async {
  try {
    final FirebaseFirestore _firebase = FirebaseFirestore.instance;
    final documentSnapshot =
        await _firebase.collection('users').where('uid', isEqualTo: uid).get();

    if (documentSnapshot.size == 1) {
      Provider.of<userProvider>(context, listen: false).setUser({
        "name": documentSnapshot.docs.first['name'],
        "profilepic": documentSnapshot.docs.first['profileImageUrl'],
        'uid': uid
      });
    } else {
      print('no data in snapshot');
    }
  } catch (error) {
    print("Error checking document: $error");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print(user!.uid);
      fetchDocument(user!.uid, context);
    }
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: user != null ? WelcomePage() : HomePage());
  }
}
