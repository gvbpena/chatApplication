import 'package:chatappv2/chat/edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // final currentUser = FirebaseAuth.instance.currentUser!;
  String? name;
  String? email;
  String? image;
  String? password;
  late bool isObscure;
  final profileQuery = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  @override
  void initState() {
    isObscure = true;
    profileQuery.then(
      (value) {
        setState(() {
          name = value['name'];
          email = value['email'];
          image = value['image'];
          password = value['password'];
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    if (name == null || email == null || image == null || password == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white,
              onPressed: () {
                logOutAction();
              },
            ),
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
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final data = snapshot.requireData;
            return ListView(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        backgroundImage: (image != "-")
                            ? NetworkImage(image!)
                            : const NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/chatapp-db519531.appspot.com/o/default_profile%2Fno_profile1.png?alt=media&token=9d901788-737f-400a-ab9a-6488a83b4ee6'),
                        radius: 80,
                        backgroundColor: Colors.white,
                      ),
                      // Text(),
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfile(
                                      id: currentUser.uid,
                                      email: data['email'],
                                      image: data['image'],
                                      name: data['name'],
                                      password: data['password'],
                                    ),
                                  ));
                            },
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(25),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: Text('Edit Profile',
                                style: TextStyle(color: Colors.grey[700])),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Divider(
                              color: Colors.grey[700],
                              height: 5,
                              thickness: 2,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                "PERSONAL INFO",
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                            ],
                          ),
                          ListTile(
                            title: Text(
                              "Name",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              data['name'],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(
                              Icons.person,
                              color: Colors.grey[700],
                              size: 32,
                            ),
                          ),
                          ListTile(
                            title: Text(
                              "Email",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              data['email'],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            leading: Icon(
                              Icons.email,
                              color: Colors.grey[700],
                              size: 32,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  // loggedinNotif() {
  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //     content: Text("Sending Message"),
  //   ));
  // }

  Widget imgExist(img) => CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(img),
      );

  // Widget imgNotExist() => const Icon(
  //       color: Colors.white,
  //       Icons.account_circle_rounded,
  //       size: 60,
  //     );
  Widget imgNotExist() => CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Image.asset(
          'assets/images/user_icon.png',
          height: 250,
          fit: BoxFit.cover,
        ),
      );

  void logOutAction() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Confirmation'),
        message: const Text('Are you sure you want to Logout?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              // deleteUser(id);
              // Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Text(
                        "Logged out successfully",
                      ),
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                    ],
                  )));
            },
            child: const Text('Continue'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
