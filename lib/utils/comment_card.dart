import 'package:blackcoffer_video/Screens/WelcomePage.dart';
import 'package:blackcoffer_video/providers/user_provider.dart';
import 'package:blackcoffer_video/resources/firebase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snap;
  // ignore: prefer_typing_uninitialized_variables
  final postId;
  final bool shareable;

  const CommentCard(
      {Key? key,
      required this.snap,
      required this.postId,
      required this.shareable})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CommentCardState createState() => _CommentCardState();
}

final TextEditingController replyController = TextEditingController();

class _CommentCardState extends State<CommentCard> {
  var onReply = false;

  @override
  Widget build(BuildContext context) {
    final daysago = calculateDaysAgo(widget.snap.data()['datePublished']);
    final userP = Provider.of<userProvider>(context).user;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    // AssetImage('images/default_profile_image.png'),
                    NetworkImage(
                  widget.snap.data()['profilePic'],
                ),
                radius: 18,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: '${widget.snap.data()['name']} :',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              )),
                          TextSpan(
                              text: ' $daysago',
                              style: const TextStyle(
                                color: Colors.black,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        ' ${widget.snap.data()['text']}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: SizedBox(
                  child: widget.shareable
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              onReply = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.reply_all_outlined,
                              size: 22,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 30, top: 40),
          child: onReply
              ? Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 4,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              onReply = false;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(userP.profilepic),
                        radius: 13,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 8),
                          child: TextField(
                            controller: replyController,
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(fontSize: 15),
                              hintText:
                                  'Reply to ${widget.snap.data()['name']}',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => {
                          FireStoreMethods().replyComment(
                              widget.postId,
                              replyController.text,
                              userP.uid,
                              userP.name,
                              userP.profilepic,
                              widget.snap.data()['commentId']),
                          replyController.text = '',
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: const Text(
                            'Reply',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
        ),
      ],
    );
  }
}
