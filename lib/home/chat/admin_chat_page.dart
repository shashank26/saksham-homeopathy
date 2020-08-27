import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/home/chat/user_chat_tile.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';

class AdminChatPage extends StatefulWidget {
  @override
  _AdminChatPageState createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage>
    with SingleTickerProviderStateMixin {
  Map<String, CollectionReference> _chatStreamRef =
      new Map<String, CollectionReference>();
      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: ChatService.getChatListStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final docSnapshot = snapshot.data.documents;
              return ListView.builder(
                  itemCount: docSnapshot.length,
                  itemBuilder: (context, index) {
                    _chatStreamRef.putIfAbsent(docSnapshot[index].documentID, () => FirestoreCollection.chat(docSnapshot[index].documentID));
                    return UserChatTile(docSnapshot[index].documentID, _chatStreamRef[docSnapshot[index].documentID]);
                  });
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
