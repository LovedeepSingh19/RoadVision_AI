import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  // _uploadVideoToStorage(String id, File videoFile) async {
  //   try {
  //     final Reference ref =
  //         FirebaseStorage.instance.ref().child('videos').child('${id}.mp4');
  //     final UploadTask uploadTask = ref.putFile(videoFile);

  //     uploadTask.whenComplete(() async {
  //       final String videoUrl = await ref.getDownloadURL();
  //       print(videoUrl);
  //       return videoUrl;
  //     });
  //   } catch (error) {
  //     print('Error uploading video: $error');
  //   }
  //   // Reference ref = FirebaseStorage.instance.ref().child('videos').child(id);

  //   // UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
  //   // TaskSnapshot snap = await uploadTask;
  //   // String downloadUrl = await snap.ref.getDownloadURL();
  //   // return downloadUrl;
  // }

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

  //  _uploadImageToStorage(
  //     String id, Uint8List thumbnailData) async {
  //   try {
  //     final Reference ref =
  //         FirebaseStorage.instance.ref().child('template').child('$id.jpeg');
  //     final imageFile = File.fromRawPath(thumbnailData);
  //     print(imageFile);
  //     File('my_image.jpg').writeAsBytes(thumbnailData);

  //     final UploadTask uploadTask = ref.putData(
  //         thumbnailData, SettableMetadata(contentType: "image/jpeg"));

  //     uploadTask.whenComplete(() async {
  //       final String imageUrl = await ref.getDownloadURL();
  //       print(imageUrl);
  //       return imageUrl;
  //     });
  //   } catch (error) {
  //     print('Error uploading image: $error');
  //   }
  //   // Reference ref =
  //   //     FirebaseStorage.instance.ref().child('thumbnails').child(id);
  //   // UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
  //   // TaskSnapshot snap = await uploadTask;
  //   // String downloadUrl = await snap.ref.getDownloadURL();
  //   // return downloadUrl;
  // }

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
        commentCount: 0,
        shareCount: 0,
        title: title,
        location: location,
        videoUrl: videoUrl,
        profilePhoto: userDoc['profileImageUrl'],
        thumbnail: thumbnail,
      );

      await FirebaseFirestore.instance.collection('videos').doc().set(
            video.toJson(),
          );
      Navigator.pop(context);
    } catch (e) {
      print(e);
      // Get.snackbar(
      //   'Error Uploading Video',
      //   e.toString(),
      // );
    }
  }
}
