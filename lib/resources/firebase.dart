import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String likePost(String postId, String uid, List likes, List dislikes) {
    String res = "Some error occurred";
    try {
      if (dislikes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('videos').doc(postId).update({
          'dislikes': FieldValue.arrayRemove([uid])
        });
        _firestore.collection('videos').doc(postId).update(
          {
            'likes': FieldValue.arrayUnion([uid])
          },
        );
        res = 'liked';
      }
      if (likes.contains(uid)) {
        _firestore.collection('videos').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
        res = 'like removed';
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('videos').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
        res = 'liked';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  String dislikePost(String postId, String uid, List likes, List dislikes) {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('videos').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
        _firestore.collection('videos').doc(postId).update(
          {
            'dislikes': FieldValue.arrayUnion([uid])
          },
        );
        res = 'disliked';
      }
      if (dislikes.contains(uid)) {
        _firestore.collection('videos').doc(postId).update({
          'dislikes': FieldValue.arrayRemove([uid])
        });
        res = 'dislike removed';
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('videos').doc(postId).update({
          'dislikes': FieldValue.arrayUnion([uid])
        });
        res = 'disliked';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> replyComment(String postId, String text, String uid,
      String name, String profilePic, String commentId) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String replyId = const Uuid().v1();

        _firestore
            .collection('videos')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replys')
            .doc(replyId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'replyId': replyId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
