import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key, required this.email});

  final String email;
  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  late TextEditingController emailcontroller;
  late String error;
  @override
  void initState() {
    error = "";
    emailcontroller = TextEditingController(
      text: widget.email,
    );
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
              'Change Email',
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 24),
              child: const Text(
                "Email ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.grey[100],
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.topLeft,
            child: TextField(
              controller: emailcontroller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
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

  checkValid() {
    if (!emailcontroller.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 2),
          content: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Text(
                "Invalid Email",
              ),
              Icon(
                Icons.check,
                color: Colors.green,
              )
            ],
          )));
    } else {
      changeEmail(emailcontroller.text);
    }
  }

  Future changeEmail(String email) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    try {
      currentUser.updateEmail(email).whenComplete(() => docUser.update({
            'email': email,
          }));
      changeSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message.toString();
      });
    }
    Navigator.pop(context);
  }

  changeSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 2),
        content: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              "Email change successfully please login again",
            ),
            Icon(
              Icons.check,
              color: Colors.green,
            )
          ],
        )));
    Navigator.pop(context);
    FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
  }
}
