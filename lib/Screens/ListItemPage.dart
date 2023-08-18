import 'package:flutter/material.dart';

class ListItemPage extends StatefulWidget {
  ListItemPage({Key? key}) : super(key: key);

  @override
  _ListItemPageState createState() => _ListItemPageState();
}

class _ListItemPageState extends State<ListItemPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("test"),
    );
  }
}


// import 'package:flutter/material.dart';

// class ListItemPage extends StatefulWidget {
//   ListItemPage({Key? key}) : super(key: key);

//   @override
//   _ListItemPageState createState() => _ListItemPageState();
// }

// class _ListItemPageState extends State<ListItemPage> {
//    late VideoPlayerController controller;
//   TextEditingController _titleController = TextEditingController();
//   TextEditingController _locationController = TextEditingController();

//   UploadVideoController uploadVideoController =
//       Get.put(UploadVideoController());

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       controller = VideoPlayerController.file(widget.videoFile);
//     });
//     controller.initialize();
//     controller.play();
//     controller.setVolume(1);
//     controller.setLooping(true);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 30,
//             ),
//             SizedBox(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height / 1.5,
//               child: VideoPlayer(controller),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 10),
//                     width: MediaQuery.of(context).size.width - 20,
//                     child: TextFormField(
//                       controller: _titleController,
//                       decoration: const InputDecoration(
//                         hintText: " Title",
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 10),
//                     width: MediaQuery.of(context).size.width - 20,
//                     child: TextFormField(
//                       controller: _locationController,
//                       enabled: false,
//                       decoration: const InputDecoration(
//                         hintText: "location",
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   ElevatedButton(
//                       onPressed: () => uploadVideoController.uploadVideo(
//                           _titleController.text,
//                           _locationController.text,
//                           widget.videoPath),
//                       child: const Text(
//                         'Share!',
//                         style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.white,
//                         ),
//                       ))
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
