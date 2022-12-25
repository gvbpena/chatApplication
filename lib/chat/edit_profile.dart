import 'package:chatappv2/chat/edit_profile/change_email.dart';
import 'package:chatappv2/chat/edit_profile/change_name.dart';
import 'package:chatappv2/chat/edit_profile/change_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../login_page.dart';
import 'edit_profile/change_image.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(
      {super.key,
      required this.id,
      required this.name,
      required this.email,
      required this.password,
      required this.image});
  final String id;
  final String name;
  final String email;
  final String password;
  final String image;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late TextEditingController emailcontroller;
  late TextEditingController passwordcontroller;
  late TextEditingController namecontroller;
  late TextEditingController confirmpasswordcontroller;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  late String imgUrl;
  late String error;

  @override
  void initState() {
    namecontroller = TextEditingController(
      text: widget.name,
    );
    emailcontroller = TextEditingController(
      text: widget.email,
    );
    passwordcontroller = TextEditingController(
      text: widget.password,
    );
    imgUrl = widget.image;
    super.initState();
    error = "";
    confirmpasswordcontroller = TextEditingController();
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    namecontroller.dispose();
    confirmpasswordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              CircleAvatar(
                backgroundImage: (widget.image != "-")
                    ? NetworkImage(widget.image)
                    : const NetworkImage(
                        'https://firebasestorage.googleapis.com/v0/b/chatapp-db519531.appspot.com/o/default_profile%2Fno_profile1.png?alt=media&token=9d901788-737f-400a-ab9a-6488a83b4ee6'),
                radius: 80,
                backgroundColor: Colors.white,
                // foregroundColor: Colors.red,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton.small(
                        onPressed: () {
                          // selectFile();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeImage(
                                  image: widget.image,
                                ),
                              ));
                        },
                        child: const Icon(Icons.edit),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                child: SizedBox(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeName(
                                  name: widget.name,
                                ),
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              const Text(
                                'Change Name',
                                style: TextStyle(fontSize: 15),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey[700],
                                size: 24.0,
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePassword(
                                  password: widget.password,
                                ),
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              const Text(
                                'Change Password',
                                style: TextStyle(fontSize: 15),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey[700],
                                size: 24.0,
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeEmail(
                                  email: widget.email,
                                ),
                              ));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              const Text(
                                'Change Email',
                                style: TextStyle(fontSize: 15),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey[700],
                                size: 24.0,
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          deleteAction(context, currentUser.uid);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              const Text(
                                'Delete Account',
                                style: TextStyle(fontSize: 15),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey[700],
                                size: 24.0,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteAction(BuildContext context, String id) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Warning!',
          style: TextStyle(color: Colors.red),
        ),
        message: const Text(
            'Are you sure you want to delete this user? Doing this will not undo any changes.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              deleteUser(id);
            },
            child: const Text('Continue'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  deleteUser(String id) {
    final docUser = FirebaseFirestore.instance.collection('users').doc(id);
    final currentUser = FirebaseAuth.instance.currentUser;
    currentUser?.delete();
    docUser
        .delete()
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 1),
            content: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                Text(
                  "Account Deleted Successfully",
                ),
                Icon(
                  Icons.check,
                  color: Colors.green,
                )
              ],
            ))));
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ));
  }
}
