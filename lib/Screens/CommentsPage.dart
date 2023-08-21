import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController =
      TextEditingController();
  final TextEditingController replyController = TextEditingController();
  var onReply = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.postId)
          .collection('comments')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (ctx, index) => SizedBox(
            width: double.infinity, // Constrain the width of the container
            child: Column(
              children: [
                CommentCard(
                  postId: widget.postId,
                  shareable: true,
                  snap: snapshot.data!.docs[index],
                ),
                SizedBox(
                  height: 140,
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('videos')
                        .doc(widget.postId)
                        .collection('comments')
                        .doc(snapshot.data!.docs[index].data()['commentId'])
                        .collection('replys')
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 40, right: 30, top: 10),
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) => SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Column(
                                children: [
                                  CommentCard(
                                    postId: widget.postId,
                                    shareable: false,
                                    snap: snapshot.data!.docs[index],
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
