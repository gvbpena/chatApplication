import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChangeImage extends StatefulWidget {
  ChangeImage({super.key, required this.image});

  String image;
  @override
  State<ChangeImage> createState() => _ChangeImageState();
}

class _ChangeImageState extends State<ChangeImage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  String error = '';
  late String imgUrl;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  bool setImage = false;
  // late TextEditingController namecontroller;
  @override
  void initState() {
    imgUrl = widget.image;
    // namecontroller = TextEditingController(
    //   text: widget.image,
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upload Image',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            TextButton(
              onPressed: () {
                uploadFile();
              },
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            )
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 24, top: 10),
              child: const Text(
                "Image",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          CircleAvatar(
            maxRadius: 60,
            backgroundColor: Colors.grey[200],
            child: (pickedFile == null) ? checkImgVal() : imgExist(),
          ),
          ElevatedButton(
              onPressed: () {
                selectFile();
              },
              child: const Text('Select File')),
          buildProgress()
        ],
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      setImage = true;
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    final path = currentUser.uid + DateTime.now().toString();
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    try {
      setState(() {
        uploadTask = ref.putFile(file);
      });
    } on FirebaseException catch (e) {
      setState(() {
        error = e.message.toString();
      });
    }

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    updateUser(currentUser.uid, urlDownload);
    setState(() {
      uploadTask = null;
    });
  }

  Future updateUser(String id, String image) async {
    try {
      final docUser = FirebaseFirestore.instance.collection('users').doc(id);
      await docUser.update({
        'image': image.trim(),
      });
      setState(() {
        error = '';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message.toString();
      });
    }
    if (error == '') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              Text(
                "update done",
              ),
              Icon(
                Icons.check,
                color: Colors.green,
              )
            ],
          )));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: double.infinity,
        fit: BoxFit.cover,
      );

  Widget imgNotExist() => Image.network(
        imgUrl,
        width: double.infinity,
        fit: BoxFit.cover,
      );

  Widget imgNotExistBlank() => CircleAvatar(
        backgroundColor: Colors.grey[200],
        maxRadius: 70,
        child: Image.asset(
          'assets/images/no-image.png',
          // fit: BoxFit.cover,
        ),
      );

  Widget checkImgVal() {
    return (imgUrl == '-') ? imgNotExistBlank() : imgNotExist();
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
          );
        }
      });
}
