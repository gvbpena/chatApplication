import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChangePassword extends StatefulWidget {
  ChangePassword({super.key, required this.password});

  String password;
  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  TextEditingController newpasswordcontroller = TextEditingController();
  late String error;
  late String correctPassword;

  final profileQuery = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  @override
  void initState() {
    error = "";
    profileQuery.then(
      (value) {
        setState(() {
          correctPassword = value['password'];
        });
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    passwordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    newpasswordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Change password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            GestureDetector(
              onTap: checkValid,
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 15),
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
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  controller: passwordcontroller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: ' Enter current password',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  controller: confirmpasswordcontroller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: ' Confirm current password',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text('Change to'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  controller: newpasswordcontroller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: ' new password',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Future _changePassword(String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser!;
    try {
      user.updatePassword(newPassword).then((_) {
        changeSuccess();
      }).catchError((error) {
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      } else if (e.code == 'wrong-password') {}
    }
  }

  // Future ChangePassword() async {}

  checkValid() {
    if (passwordcontroller.text != correctPassword) {
      setState(() {
        error = 'Incorrect Password';
        // hasError(error);
      });
    } else if (passwordcontroller.text != confirmpasswordcontroller.text) {
      setState(() {
        error = "wrong password confirmation";
        // hasError(error);
      });
    } else if (newpasswordcontroller.text.isEmpty ||
        passwordcontroller.text.isEmpty ||
        confirmpasswordcontroller.text.isEmpty) {
      setState(() {
        error = 'Empty input';
        // hasError(error);
      });
    } else {
      _changePassword(passwordcontroller.text, newpasswordcontroller.text);
    }
  }

  changeSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 2),
        content: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              "password change successfully",
            ),
            Icon(
              Icons.check,
              color: Colors.green,
            )
          ],
        )));
    Navigator.pop(context);
    // FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
  }
}
