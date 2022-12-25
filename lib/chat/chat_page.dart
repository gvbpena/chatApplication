import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'conversation_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController searchcontroller;
  String filter = "";
  @override
  void initState() {
    searchcontroller = TextEditingController();
    super.initState();
  }

  final Stream<QuerySnapshot> userQuery =
      FirebaseFirestore.instance.collection('users').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
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
      // backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    filter = value;
                  });
                },
                controller: searchcontroller,
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: userQuery,
                builder: ((BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final datas = snapshot.requireData;
                  return SizedBox(
                    height: 1000,
                    child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: datas.size,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        if (filter.isEmpty) {
                          return ConversationList(
                            image: datas.docs[index]['image'],
                            name: datas.docs[index]['name'],
                            email: datas.docs[index]['email'],
                            id: datas.docs[index]['id'],
                          );
                        }
                        if (data['name']
                            .toString()
                            .toLowerCase()
                            .startsWith(filter.toLowerCase())) {
                          return ConversationList(
                            image: data['image'],
                            name: data['name'],
                            email: data['email'],
                            id: data['id'],
                          );
                        }
                        return Container();
                      },
                    ),
                  );
                })),
          ],
        ),
      ),
    );
  }
}
