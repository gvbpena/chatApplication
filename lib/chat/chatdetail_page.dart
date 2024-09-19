import 'package:chatappv2/chat/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/message_model.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  final String email;
  final String id;
  final String image;

  const ChatDetailPage({
    super.key,
    required this.name,
    required this.email,
    required this.id,
    required this.image,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  // String temp = widget.id.toString();
  final currentUser = FirebaseAuth.instance.currentUser!;
  Stream<QuerySnapshot>? filteredMessage;
  late TextEditingController messagecontroller;
  String like = "";
  @override
  void initState() {
    messagecontroller = TextEditingController();
    readMessage();
    super.initState();
  }

  @override
  void dispose() {
    messagecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundImage: (widget.image != "-")
                      ? NetworkImage(widget.image)
                      : const NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/chatapp-db519531.appspot.com/o/default_profile%2Fno_profile1.png?alt=media&token=9d901788-737f-400a-ab9a-6488a83b4ee6'),
                  radius: 33,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: filteredMessage,
                  builder: ((BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    return chatMessages(snapshot);
                  })),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          like = value;
                        });
                      },
                      controller: messagecontroller,
                      decoration: const InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  (like.isEmpty)
                      ? FloatingActionButton(
                          onPressed: () {
                            createMessage('waving_hand:519531');
                          },
                          backgroundColor: Colors.white,
                          elevation: 0,
                          child: const Icon(
                            Icons.waving_hand,
                            color: Colors.blue,
                            size: 18,
                          ),
                        )
                      : FloatingActionButton(
                          onPressed: () {
                            createMessage(messagecontroller.text);
                          },
                          backgroundColor: Colors.white,
                          elevation: 0,
                          child: const Icon(
                            Icons.send,
                            color: Colors.blue,
                            size: 18,
                          ),
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  chatMessages(snapshot) {
    if (snapshot.hasError) {
      return const Center(
        child: Text("something went wrong"),
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (!snapshot.hasData) {
      return const Center(
        child: Text(' '),
      );
    }
    if (snapshot.hasData) {
      if (snapshot.requireData.size == 0) {
        return const Center(
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text("You don't have a conversation yet; say hello! "),
                  Icon(
                    Icons.waving_hand,
                    color: Colors.blue,
                    size: 20.0,
                  ),
                ],
              ),
            ],
          ),
        );
      }
      final data = snapshot.requireData;
      return ListView.builder(
        shrinkWrap: true,
        itemCount: data.size,
        itemBuilder: (context, index) {
          return MessageList(
            messages: data.docs[index]['message'],
            sender: data.docs[index]['sender'],
            receiver: data.docs[index]['receiver'],
            email: widget.email,
          );
        },
      );
    }
  }

  Future readMessage() async {
    final collection1 = FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(currentUser.uid.toString() + widget.id)
        .orderBy('dateTime')
        .snapshots();
    final collection2 = FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(widget.id + currentUser.uid.toString())
        .orderBy('dateTime')
        .snapshots();
    final existingCollection1 = await FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(currentUser.uid.toString() + widget.id)
        .get();
    final existingCollection2 = await FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(widget.id + currentUser.uid.toString())
        .get();
    if (existingCollection1.size == 0 && existingCollection2.size == 0) {
      setState(() {
        filteredMessage = collection1;
      });
    }
    if (existingCollection2.size != 0 && existingCollection1.size == 0) {
      setState(() {
        filteredMessage = collection2;
      });
    }
    if (existingCollection1.size != 0 && existingCollection2.size == 0) {
      setState(() {
        filteredMessage = collection1;
      });
    }
    if (existingCollection1.size != 0 && existingCollection2.size != 0) {
      setState(() {
        filteredMessage = collection2;
      });
    }
  }

  Future createMessage(String message) async {
    final collection1 = FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(currentUser.uid.toString() + widget.id);
    final collection2 = FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(widget.id + currentUser.uid.toString());
    final existingCollection1 = await FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(currentUser.uid.toString() + widget.id)
        .get();
    final existingCollection2 = await FirebaseFirestore.instance
        .collection('chats')
        .doc('messageRoom')
        .collection(widget.id + currentUser.uid.toString())
        .get();

    if (existingCollection1.size == 0 && existingCollection2.size == 0) {
      final docMessage = collection1;
      final newMessage = Chat_messages(
        message: message,
        sender: currentUser.uid.toString(),
        receiver: widget.id,
        dateTime: DateTime.now().toString(),
      );

      final json = newMessage.toJson();
      await docMessage.add(json);
    }
    if (existingCollection1.size != 0 && existingCollection2.size == 0) {
      final docMessage = collection1;
      final newMessage = Chat_messages(
        message: message,
        sender: currentUser.uid.toString(),
        receiver: widget.id,
        dateTime: DateTime.now().toString(),
      );

      final json = newMessage.toJson();
      await docMessage.add(json);
    }
    if (existingCollection2.size != 0 && existingCollection1.size == 0) {
      final docMessage = collection2;
      final newMessage = Chat_messages(
        message: message,
        sender: currentUser.uid.toString(),
        receiver: widget.id,
        dateTime: DateTime.now().toString(),
      );

      final json = newMessage.toJson();
      await docMessage.add(json);
    }
    if (existingCollection1.size != 0 && existingCollection2.size != 0) {
      final docMessage = collection1;
      final newMessage = Chat_messages(
        message: message,
        sender: currentUser.uid.toString(),
        receiver: widget.id,
        dateTime: DateTime.now().toString(),
      );

      final json = newMessage.toJson();
      await docMessage.add(json);
    }
    setState(() {
      messagecontroller.clear();
      like = "";
    });
  }
}
