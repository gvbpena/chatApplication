import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chatdetail_page.dart';

// ignore: must_be_immutable
class ConversationList extends StatefulWidget {
  String name;
  String email;
  String id;
  String image;
  ConversationList({
    super.key,
    required this.name,
    required this.email,
    required this.id,
    required this.image,
  });
  @override
  // ignore: library_private_types_in_public_api
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ChatDetailPage(
            email: widget.email,
            name: widget.name,
            id: widget.id,
            image: widget.image,
          );
        }));
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: (widget.image != "-")
                        ? NetworkImage(widget.image)
                        : const NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/b/chatapp-db519531.appspot.com/o/default_profile%2Fno_profile1.png?alt=media&token=9d901788-737f-400a-ab9a-6488a83b4ee6'),
                    radius: 33,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          (currentUser.email == widget.email)
                              ? Text(
                                  '${widget.name} (You)',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  widget.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
