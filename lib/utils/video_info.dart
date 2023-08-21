import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:blackcoffer_video/resources/firebase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../modals/videos_modal.dart';
import '../providers/user_provider.dart';

class VideoInfo extends StatefulWidget {
  final Video videoData;

  const VideoInfo({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VideoInfoState createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {
  String? res;

  @override
  Widget build(BuildContext context) {
    final userP = Provider.of<userProvider>(context).user;

    if (widget.videoData.likes.contains(userP.uid)) {
      setState(() {
        res = "liked";
      });
    }
    if (widget.videoData.dislikes.contains(userP.uid)) {
      setState(() {
        res = "disliked";
      });
    }
    String daysago = calculateDaysAgo(widget.videoData.timestamp);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.videoData.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.videoData.views} views • $daysago',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 14.0),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(widget.videoData.Category),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  res = FireStoreMethods().likePost(
                      widget.videoData.id,
                      userP.uid,
                      widget.videoData.likes,
                      widget.videoData.dislikes);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("you liked this post, refresh to see changes")));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 2.0),
                    Icon(
                      Icons.thumb_up_outlined,
                      color: res == 'liked' ? Colors.blue.shade400 : null,
                    ),
                    Text(
                      '${widget.videoData.likes.length}',
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  res = FireStoreMethods().dislikePost(
                      widget.videoData.id,
                      userP.uid,
                      widget.videoData.likes,
                      widget.videoData.dislikes);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "you disliked this post, refresh to see changes")));
                  // print();
                  // FireStoreMethods().likePost(, uid, likes)
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 2.0),
                    Icon(
                      Icons.thumb_down_outlined,
                      color: res == 'disliked' ? Colors.red.shade400 : null,
                    ),
                    Text(
                      '${widget.videoData.dislikes.length}',
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Share.share(
                      "Hey Check out this cool video : ${widget.videoData.videoUrl}");
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 2.0),
                    Icon(
                      Icons.reply_outlined,
                    ),
                    Text(
                      'Share',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 2,
          ),
          const Divider(
            thickness: 3,
          ),
          _AuthorInfo(videoData: widget.videoData),
          const Divider(
            thickness: 3,
          ),
        ],
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final Video videoData;
  const _AuthorInfo({Key? key, required this.videoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('Navigate to profile'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              CircleAvatar(
                foregroundImage: NetworkImage(videoData.profilePhoto),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 60, top: 8),
                child: Text(videoData.username,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WelcomePage(
                            filter: 'timestamp',
                            whereC: 'uid',
                            whereV: videoData.uid,
                          )));
            },
            child: const Text(
              'View all videos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }
}
