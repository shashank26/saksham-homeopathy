import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/home/chat/user_chat_tile.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';

class AdminChatPage extends StatefulWidget {
  @override
  _AdminChatPageState createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage>
    with SingleTickerProviderStateMixin {
  Map<String, CollectionReference> _chatStreamRef =
      new Map<String, CollectionReference>();
  List<MapEntry<String, CollectionReference>> _searchedRefs = [];
  Map<String, ProfileInfo> _profiles = new Map();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPallete.color,
      appBar: AppBar(
        backgroundColor: AppColorPallete.backgroundColor,
        title: Container(
          width: double.maxFinite,
          color: AppColorPallete.backgroundColor,
          child: HeaderText(
            "Chats",
            align: TextAlign.left,
            size: 40,
          ),
        ),
        actions: [
          IconButton(
                    icon: isSearching ? Icon(Icons.close) : Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        isSearching = !isSearching;
                        if (isSearching) {
                          _searchedRefs = _chatStreamRef.entries.toList();
                        }
                      });
                    },
                    color: AppColorPallete.textColor,
                    iconSize: 30,
                  )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top : 8),
        child: Column(
          children: [
            Visibility(
              visible: isSearching,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                child: Column(
                  children: [
                    CTextFormField(
                      autoFocus: true,
                      prefixIcon: Icon(Icons.search),
                      onChanged: (val) {
                        final filtered = HashMap.fromEntries(_profiles.entries
                            .where((entry) =>
                                entry.value.displayName.toLowerCase().startsWith(val.toLowerCase()) ||
                                entry.value.phoneNumber
                                    .substring(3)
                                    .startsWith(val)));
                        setState(() {
                          _searchedRefs = _chatStreamRef.entries
                              .where((element) =>
                                  filtered.keys.contains(element.key))
                              .toList();
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: ChatService.getChatListStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length == 0) {
                          return Center(
                              child: Text(
                            "No chats initiated.",
                            style: TextStyle(color: AppColorPallete.textColor),
                          ));
                        }
                        final docSnapshot = snapshot.data.documents;
                        return ListView.builder(
                            itemCount: isSearching
                                ? _searchedRefs.length
                                : docSnapshot.length,
                            itemBuilder: (context, index) {
                              _chatStreamRef.putIfAbsent(
                                  docSnapshot[index].documentID,
                                  () => FirestoreCollection.chat(
                                      docSnapshot[index].documentID));
                              return isSearching
                                  ? UserChatTile(
                                      _searchedRefs[index].key,
                                      _searchedRefs[index].value,
                                      (String uid, ProfileInfo info) {})
                                  : UserChatTile(
                                      docSnapshot[index].documentID,
                                      _chatStreamRef[
                                          docSnapshot[index].documentID],
                                      (String uid, ProfileInfo info) {
                                      _profiles.putIfAbsent(uid, () => info);
                                    });
                            });
                      }
                      return CircularProgressIndicator();
                    })),
          ],
        ),
      ),
    );
  }
}
