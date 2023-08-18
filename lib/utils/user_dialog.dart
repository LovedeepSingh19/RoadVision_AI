import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../Screens/WelcomePage.dart';
import '../providers/user_provider.dart';

class UserDialog extends StatefulWidget {
  UserDialog({Key? key}) : super(key: key);

  @override
  _UserDialogState createState() => _UserDialogState();
}

File? _selectedImage;
final TextEditingController _codeController = TextEditingController();
final user = FirebaseAuth.instance.currentUser;

bool _isButtonDisabled = false;

final TextEditingController _nameController = TextEditingController();
dynamic _pickImageError;

class _UserDialogState extends State<UserDialog> {
  void _disableButtonForSeconds(int seconds) {
    setState(() {
      _isButtonDisabled = true;
    });

    Timer(Duration(seconds: seconds), () {
      setState(() {
        _isButtonDisabled = false;
      });
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      _disableButtonForSeconds(5);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      setState(() {
        print(e);
        _pickImageError = e;
      });
    }
  }

  Future<void> _uploadProfileData() async {
    final name = _nameController.text;

    if (_selectedImage != null && name.isNotEmpty) {
      try {
        final storageRef =
            FirebaseStorage.instance.ref().child('profile_pictures');
        final imageRef = storageRef
            .child('profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await imageRef.putFile(_selectedImage!);

        final imageUrl = await imageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc().set({
          'name': name,
          'profileImageUrl': imageUrl,
          'uid': user!.uid,
        });

        // ignore: use_build_context_synchronously
        Provider.of<userProvider>(context, listen: false)
            .setUser({"name": name, "profilepic": imageUrl, 'uid': user!.uid});
        // Navigator.pop(context); // Close the dialog
        // ignore: use_build_context_synchronously
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => WelcomePage()));
      } catch (error) {
        print("Error uploading profile data: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: FloatingActionButton(
                shape: CircleBorder(),
                onPressed: () => _pickImage(ImageSource.gallery),
                child: _isButtonDisabled
                    ? const CircleAvatar(
                        radius: 50, child: CircularProgressIndicator())
                    : CircleAvatar(
                        radius: 50,
                        child: null,
                        backgroundImage: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ).image
                            : const AssetImage(
                                'images/default_profile_image.png'),
                      )),
          ),
          const SizedBox(height: 10),
          const Text("Upload Profile Picture"),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _uploadProfileData,
          child: const Text("Upload"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
