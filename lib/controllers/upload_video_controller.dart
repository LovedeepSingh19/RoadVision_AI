import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';

import '../modals/videos_modal.dart';

class UploadVideoController extends GetxController {
  _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    print(compressedVideo);
    return compressedVideo!.file;
  }

  Future<String> uploadVideoToStorage(String id, File videoFile) async {
    final Reference ref =
        FirebaseStorage.instance.ref().child('videos').child('${id}.mp4');
    final UploadTask uploadTask = ref.putFile(videoFile);

    final completer = Completer<String>();

    uploadTask.whenComplete(() async {
      final String videoUrl = await ref.getDownloadURL();
      print(videoUrl);
      completer.complete(videoUrl);
    }).catchError((error) {
      print('Error uploading video: $error');
      completer.completeError(error);
    });

    return completer.future;
  }

  Future<String> uploadImageToStorage(
      String id, Uint8List thumbnailData) async {
    final Reference ref =
        FirebaseStorage.instance.ref().child('template').child('$id.jpeg');

    final UploadTask uploadTask =
        ref.putData(thumbnailData, SettableMetadata(contentType: "image/jpeg"));

    final completer = Completer<String>();

    uploadTask.whenComplete(() async {
      final String imageUrl = await ref.getDownloadURL();
      print(imageUrl);
      completer.complete(imageUrl);
    }).catchError((error) {
      print('Error uploading image: $error');
      completer.completeError(error);
    });

    return completer.future;
  }

  // upload video
  uploadVideo(String title, String location, Uint8List thumbnailData,
      String category, File videoFile, context) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where("uid", isEqualTo: uid)
          .get();
      // get id
      DocumentSnapshot userDoc = userDocs.docs.first;
      var allDocs = await FirebaseFirestore.instance.collection('videos').get();
      int len = allDocs.docs.length;
      String videoUrl =
          await uploadVideoToStorage("Video $len $title", videoFile);
      print("out Video: " + videoUrl);
      String thumbnail =
          await uploadImageToStorage("Video $len $title", thumbnailData);
      print("out thumbnail: " + thumbnail);

      Video video = Video(
          username: userDoc['name'],
          uid: uid,
          id: "Video $len $title",
          likes: [],
          dislikes: [],
          Category: category,
          views: 0,
          title: title,
          location: location,
          videoUrl: videoUrl,
          profilePhoto: userDoc['profileImageUrl'],
          thumbnail: thumbnail,
          timestamp: Timestamp.now());

      await FirebaseFirestore.instance
          .collection('videos')
          .doc("Video $len $title")
          .set(
            video.toJson(),
          );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$title uploaded")));
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }
}
