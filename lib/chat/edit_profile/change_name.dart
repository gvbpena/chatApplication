import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChangeName extends StatefulWidget {
  ChangeName({super.key, required this.name});

  String name;
  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  late TextEditingController namecontroller;
  @override
  void initState() {
    namecontroller = TextEditingController(
      text: widget.name,
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
              'Change Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            GestureDetector(
              onTap: changeName,
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
                "Name",
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
              controller: namecontroller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future changeName() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    await docUser.update({
      'name': namecontroller.text.trim(),
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 2),
          content: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Name changed to ${namecontroller.text.trim()}",
              ),
              const Icon(
                Icons.check,
                color: Colors.green,
              )
            ],
          )));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    });
  }
}
