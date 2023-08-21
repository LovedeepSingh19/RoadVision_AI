import 'dart:io';
import 'dart:typed_data';

import 'package:blackcoffer_video/constants/category_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_geocoder/geocoder.dart';

import '../controllers/upload_video_controller.dart';

class VideoPage extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  final LocationData locationdata;
  VideoPage(
      {Key? key,
      required this.locationdata,
      required this.videoFile,
      required this.videoPath})
      : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  TextEditingController _titleController = TextEditingController();
  String selectedValue = ''; // Initially no value is selected

  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());

  Uint8List? thumbnailData;
  bool isUploading = false;

  String? loc;

  Future<void> getAddressFromCoordinates(Coordinates coordinates) async {
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = addresses.first;
    setState(() {
      loc = "${first.locality}, ${first.countryName}";
    });
  }

  @override
  void initState() {
    super.initState();
    generateThumbnail();
  }

  @override
  void dispose() {
    super.dispose();
    isUploading = false;
  }

  Future<void> generateThumbnail() async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: widget.videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 50,
    );

    setState(() {
      thumbnailData = uint8list;
    });
  }

  @override
  Widget build(BuildContext context) {
    Coordinates newCords = new Coordinates(
        widget.locationdata.latitude, widget.locationdata.longitude);
    getAddressFromCoordinates(newCords);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 42,
            ),
            SizedBox(
              child: thumbnailData != null
                  ? Image.memory(thumbnailData!)
                  : CircularProgressIndicator(),
            ),
            const SizedBox(
              height: 30,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 40, right: 40, top: 8, bottom: 8),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextFormField(
                        controller: _titleController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: " Title",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 40, right: 40, top: 8, bottom: 8),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: loc,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 40, right: 40, top: 8, bottom: 8),
                    child: DropdownButtonFormField<String>(
                      value: categoryList[0],
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue = newValue!;
                        });
                      },
                      items: categoryList.map((item) {
                        return DropdownMenuItem<String>(
                          value: item, // Ensure each value is unique
                          child: Text(item),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isUploading = true;
                        });
                        await uploadVideoController.uploadVideo(
                          _titleController.text,
                          loc!,
                          thumbnailData!,
                          selectedValue ?? categoryList[0],
                          widget.videoFile,
                          context,
                        );
                        setState(() {
                          isUploading = false;
                        });
                      },
                      child: isUploading
                          ? CircularProgressIndicator()
                          : const Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            )),
                  if (isUploading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: (Text("please wait your post is uploading")),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
