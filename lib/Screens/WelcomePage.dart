import 'dart:io';
import 'package:blackcoffer_video/Screens/Homepage.dart';
import 'package:blackcoffer_video/Screens/VideoItemPage.dart';
import 'package:blackcoffer_video/Screens/VideoUploadPage.dart';
import 'package:blackcoffer_video/utils/filter_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../modals/videos_modal.dart';

// ignore: must_be_immutable
class WelcomePage extends StatefulWidget {
  String filter;
  bool? desc;
  String? whereC;
  String? whereV;
  WelcomePage(
      {Key? key, required this.filter, this.desc, this.whereC, this.whereV})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WelcomePageState createState() => _WelcomePageState();
}

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),
    );
  }
}

String calculateDaysAgo(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  DateTime now = DateTime.now();
  Duration difference = now.difference(dateTime);

  int days = difference.inDays;

  if (days == 0) {
    return 'Today';
  } else if (days == 1) {
    return 'Yesterday';
  } else {
    return '$days days ago';
  }
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _onTextChanged = TextEditingController();
  var onSearched = false;

  bool onClicked = false;
  Video? videoData;

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // ignore: avoid_print
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
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoadingDialog();
      },
    );
    // ignore: no_leading_underscores_for_local_identifiers
    LocationData _locationData = await location.getLocation();
    if (video != null) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
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

  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    var userf = FirebaseAuth.instance.currentUser;
    if (userf == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          widthFactor: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade300
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(16, 132, 129, 129),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: screenWidth / 1.45,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: TextFormField(
                              controller: _onTextChanged,
                              onFieldSubmitted: (String val) {
                                if (val != '') {
                                  setState(() {
                                    onClicked = false;
                                    onSearched = true;
                                  });
                                } else {
                                  setState(() {
                                    onSearched = false;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                              ),
                            )),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.search,
                          color: Color.fromARGB(255, 197, 101, 214),
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return const FilterDialogs();
                        });
                  },
                  child: const Icon(
                    Icons.filter_alt_rounded,
                    size: 30,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: screenHeight / 1.30,
                child: onClicked
                    ? VideoItemPage(videoData: videoData!)
                    : Scaffold(
                        body: onSearched
                            ? FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('videos')
                                    .where(
                                      'title',
                                      isGreaterThanOrEqualTo:
                                          _onTextChanged.text,
                                    )
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final List<Video> videos = snapshot.data!.docs
                                      .map((doc) => Video.fromSnap(doc))
                                      .toList();

                                  if (videos.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "No Posts Found",
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: videos.length,
                                    itemBuilder: (context, index) {
                                      final Video video = videos[index];
                                      print("Searched");
                                      String daysAgo =
                                          calculateDaysAgo(video.timestamp);

                                      return Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              onClicked = true;
                                              FirebaseFirestore.instance
                                                  .collection('videos')
                                                  .doc(video.id)
                                                  .update({
                                                'views': video.views + 1
                                              });
                                              videoData = video;
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  widthFactor: 0.5,
                                                  heightFactor: 1,
                                                  child: Image.network(
                                                    video.thumbnail,
                                                    width: screenWidth / 1.2,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 2, right: 2),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            video.profilePhoto),
                                                  ),
                                                  title: Text(
                                                    video.title,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  trailing: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 9),
                                                    child: SizedBox(
                                                      width:
                                                          85, // Set the desired width here
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            video.location,
                                                            style: const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 4,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              3),
                                                                  child: Icon(
                                                                    Icons
                                                                        .category_rounded,
                                                                    size: 16,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  video
                                                                      .Category,
                                                                  style: const TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            3),
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              Text(video
                                                                  .username),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            3),
                                                                child: Icon(
                                                                  Icons
                                                                      .remove_red_eye_rounded,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${video.views}',
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            3),
                                                                child: Icon(
                                                                  Icons
                                                                      .calendar_month_outlined,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              Text(
                                                                daysAgo,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            10),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                height: 5,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : StreamBuilder<QuerySnapshot>(
                                stream: widget.whereC != null
                                    ? FirebaseFirestore.instance
                                        .collection('videos')
                                        .where(widget.whereC!,
                                            isEqualTo: widget.whereV)
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('videos')
                                        .orderBy('likes',
                                            descending: widget.desc ?? false)
                                        .snapshots(),
                                // .where('Category', isEqualTo: "Gaming")

                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  print('no search');

                                  final List<Video> videos = snapshot.data!.docs
                                      .map((doc) => Video.fromSnap(doc))
                                      .toList();

                                  if (videos.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "No Posts Found, Press + Icon to Generate a new one",
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: videos.length,
                                    itemBuilder: (context, index) {
                                      final Video video = videos[index];
                                      String daysAgo =
                                          calculateDaysAgo(video.timestamp);

                                      return Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              onClicked = true;
                                              FirebaseFirestore.instance
                                                  .collection('videos')
                                                  .doc(video.id)
                                                  .update({
                                                'views': video.views + 1
                                              });
                                              videoData = video;
                                            });
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) => VideoItemPage(
                                            //       videoUrl: video.videoUrl,
                                            //     ), // Replace with your destination page
                                            //   ),
                                            // );
                                          },
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  widthFactor: 0.5,
                                                  heightFactor: 1,
                                                  child: Image.network(
                                                    video.thumbnail,
                                                    width: screenWidth / 1.2,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 2, right: 2),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            video.profilePhoto),
                                                  ),
                                                  title: Text(
                                                    video.title,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  trailing: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 9),
                                                    child: SizedBox(
                                                      width:
                                                          85, // Set the desired width here
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            video.location,
                                                            style: const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 4,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              3),
                                                                  child: Icon(
                                                                    Icons
                                                                        .category_rounded,
                                                                    size: 16,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  video
                                                                      .Category,
                                                                  style: const TextStyle(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Row(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            3),
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 18,
                                                                ),
                                                              ),
                                                              Text(video
                                                                  .username),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 6,
                                                                    right: 6),
                                                            child: Row(
                                                              children: [
                                                                const Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              3),
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove_red_eye_rounded,
                                                                    size: 16,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${video.views}',
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            3),
                                                                child: Icon(
                                                                  Icons
                                                                      .calendar_month_outlined,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              Text(
                                                                daysAgo,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            10),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                height: 5,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
              ),
              onClicked
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 243, 221, 248),
                              padding: const EdgeInsets.all(9),
                              elevation: 2,
                              maximumSize: const Size(90, 90),
                            ),
                            onPressed: () {
                              setState(() {
                                onClicked = false;
                                videoData = null;
                                onSearched = false;
                              });
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back_ios),
                                Text(
                                  "Back",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 243, 221, 248),
                              padding: const EdgeInsets.all(9),
                              elevation: 2,
                              maximumSize: const Size(90, 90),
                            ),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              if (FirebaseAuth.instance.currentUser == null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()));
                              }
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.logout_outlined),
                                Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 270, top: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 243, 221, 248),
                          padding: const EdgeInsets.all(9),
                          elevation: 2,
                          maximumSize: const Size(90, 90),
                        ),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          if (FirebaseAuth.instance.currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          }
                        },
                        // child: Text("Logout"),
                        child: const Row(
                          children: [
                            Icon(Icons.logout_outlined),
                            Text(
                              "Logout",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          pickVideo(ImageSource.camera, context);
        },
        child: const Icon(
          Icons.add,
          size: 35,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
