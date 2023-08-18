import 'dart:io';

import 'package:blackcoffer_video/Screens/ListItemPage.dart';
import 'package:blackcoffer_video/Screens/VideoPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

late List<dynamic> filteredData = [];

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _onTextChanged = TextEditingController();

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  pickVideo(ImageSource src, BuildContext context) async {
    await _requestPermission();

    Location location = Location();
    final video = await ImagePicker().pickVideo(source: src);
    LocationData _locationData = await location.getLocation();
    if (video != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPage(
            videoFile: File(video.path),
            videoPath: video.path,
            locationdata: _locationData,
          ),
        ),
      );
    }
  }

  //  void _onTextChanged(String value) {
  //     if (value != "") {
  //       setState(() {
  //         filteredData = user.contacts
  //             .where((item) =>
  //                 item['name'].toLowerCase().contains(value.toLowerCase()))
  //             .toList();
  //       });
  //       print(filteredData);
  //     } else {
  //       setState(() {
  //         filteredData = [];
  //       });
  //     }
  //   }
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final userP = Provider.of<userProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              widthFactor: 5,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60, left: 50, right: 0),
                    child: Container(
                      // padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(16, 132, 129, 129),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 230,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  child: TextFormField(
                                    controller: _onTextChanged,
                                    decoration: const InputDecoration(
                                      hintText: "Search",
                                      border: InputBorder.none,
                                    ),
                                  )),
                            ),
                            const Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 197, 101, 214),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  const Padding(
                    padding: const EdgeInsets.only(top: 55, left: 8),
                    child: Icon(
                      Icons.filter_alt_rounded,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
            ListItemPage(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          pickVideo(ImageSource.camera, context);
        },
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (context) => CameraPage()));
        // },
        //         getVideoFile(ImageSource sourceImg) async {
        //   _locationData = await location.getLocation();
        //   print(_locationData);
        //   final videoFile = ImagePicker().pickVideo(source: sourceImg,);
        //   print(videoFile);
        //   if (videoFile != null) {
        //     print('yo');
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => videopageTemp(
        //                   videoFile: File(videoFile.path),
        //                   videoPath: videoFile.path,
        //                   location: _locationData,
        //                 )
        //             // VideoPage(
        //             //       videoFile: File(videoFile.path),
        //             //       videoPath: videoFile.path,
        //             //       location: _locationData,
        //             //     )
        //             ));
        //   }
        // }
        child: const Icon(
          Icons.add,
          size: 35,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
