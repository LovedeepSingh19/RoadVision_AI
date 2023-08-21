import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  String username;
  String uid;
  String id;
  List likes;
  List dislikes;
  int views;
  String title;
  String location;
  String videoUrl;
  String thumbnail;
  String Category;
  String profilePhoto;
  Timestamp timestamp;

  Video({
    required this.username,
    required this.uid,
    required this.id,
    required this.likes,
    required this.dislikes,
    required this.views,
    required this.Category,
    required this.title,
    required this.location,
    required this.videoUrl,
    required this.profilePhoto,
    required this.thumbnail,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "profilePhoto": profilePhoto,
        "id": id,
        "likes": likes,
        "Category": Category,
        "dislikes": dislikes,
        "views": views,
        "title": title,
        "location": location,
        "videoUrl": videoUrl,
        "thumbnail": thumbnail,
        "timestamp": timestamp,
      };

  static Video fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Video(
      username: snapshot['username'],
      uid: snapshot['uid'],
      id: snapshot['id'],
      Category: snapshot['Category'],
      likes: snapshot['likes'],
      dislikes: snapshot['dislikes'],
      views: snapshot['views'],
      title: snapshot['title'],
      location: snapshot['location'],
      videoUrl: snapshot['videoUrl'],
      profilePhoto: snapshot['profilePhoto'],
      thumbnail: snapshot['thumbnail'],
      timestamp: snapshot['timestamp'],
    );
  }
}
