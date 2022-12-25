import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MessageList extends StatefulWidget {
  String messages;
  String sender;
  String receiver;
  String email;
  MessageList(
      {super.key,
      required this.messages,
      required this.sender,
      required this.receiver,
      required this.email});
  @override
  // ignore: library_private_types_in_public_api
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
        child: Align(
          // ignore: unrelated_type_equality_checks
          alignment: (widget.sender == currentUser.uid
              ? Alignment.topRight
              : Alignment.topLeft),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // ignore: unrelated_type_equality_checks
                color: (widget.sender == currentUser.uid
                    ? Colors.blue[200]
                    : Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(16),
              child: (widget.messages == 'waving_hand:519531')
                  ? const Icon(
                      Icons.waving_hand,
                      color: Colors.blue,
                      size: 18,
                    )
                  : Text(
                      widget.messages,
                      style: const TextStyle(fontSize: 15),
                    )),
        ));
  }
}
