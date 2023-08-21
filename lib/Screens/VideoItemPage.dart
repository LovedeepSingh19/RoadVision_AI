import 'dart:async';

import 'package:blackcoffer_video/Screens/CommentsPage.dart';
import 'package:blackcoffer_video/modals/videos_modal.dart';
import 'package:blackcoffer_video/providers/user_provider.dart';
import 'package:blackcoffer_video/utils/video_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../resources/firebase.dart';
import 'WelcomePage.dart';

class VideoItemPage extends StatefulWidget {
  final Video videoData;
  const VideoItemPage({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VideoItemPageState createState() => _VideoItemPageState();
}

class _VideoItemPageState extends State<VideoItemPage> {
  late VideoPlayerController _controller;
  final TextEditingController commentController = TextEditingController();

  late Timer _timer;

  String formattedDuration = '0:00 / 0:00';

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoData.videoUrl))
          ..initialize().then(
            (_) {
              setState(() {});
              _startTimer();
            },
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_controller.value.isPlaying) {
          Duration currentPosition = _controller.value.position;
          Duration videoDuration = _controller.value.duration;

          setState(
            () {
              formattedDuration =
                  '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')} / ${videoDuration.inMinutes}:${(videoDuration.inSeconds % 60).toString().padLeft(2, '0')}';
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    void postComment(String uid, String name, String profilePic) async {
      try {
        String res = await FireStoreMethods().postComment(
          widget.videoData.id,
          commentController.text,
          uid,
          name,
          profilePic,
        );

        if (res != 'success') {
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(res)));
          }
        }
        setState(() {
          commentController.text = "";
        });
      } catch (err) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err.toString())));
      }
    }

    final like = widget.videoData.likes;
    double screenHeight = MediaQuery.of(context).size.height;
    String daysAgo = calculateDaysAgo(widget.videoData.timestamp);
    final userP = Provider.of<userProvider>(context).user;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                child: _controller.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 350,
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 48,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                              });
                            },
                          ),
                          Positioned(
                            bottom: 16,
                            child: Text(
                              formattedDuration,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        children: [
                          SizedBox(
                            height: 350,
                            child: Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              VideoInfo(videoData: widget.videoData),
              SizedBox(
                height: screenHeight / 3,
                child: Scaffold(
                  // body: CommentCard(snap: ''),
                  body: Column(
                    children: [
                      // SafeArea(
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(userP.profilepic),
                              radius: 18,
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 8),
                                child: TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Comment as ${userP.name}',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => {
                                postComment(
                                  userP.uid,
                                  userP.name,
                                  userP.profilepic,
                                ),
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: const Text(
                                  'Post',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: const Divider(),
                      ),

                      // ),
                      SizedBox(
                          height: screenHeight / 4,
                          child: CommentsScreen(postId: widget.videoData.id)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
