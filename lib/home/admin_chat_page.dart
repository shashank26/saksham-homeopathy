import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/home/user_chat_tile.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';

import 'chat_page.dart';

class AdminChatPage extends StatefulWidget {
  @override
  _AdminChatPageState createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<String> _mapKeys = new List<String>();
  final HashMap<String, ChatPage> hmap = new HashMap<String, ChatPage>();
  AnimationController _animationController;
  Animation<double> animation;

  _updateChatList(List<DocumentChange> changes) {
    changes.forEach((e) {
      if (e.document.documentID != null)
        hmap.putIfAbsent(
          e.document.documentID,
          () => ChatPage(
            e.document.documentID,
            backButton: (uid) async {
              _animationController.reset();
              setState(() {
                hmap[uid].setView(false);
                _currentIndex = 0;
                _animationController.forward();
              });
            },
          ),
        );
    });
    _mapKeys.addAll(hmap.keys.where((element) => !_mapKeys.contains(element)));
  }

  @override
  void initState() {
    _animationController = AnimationController(
        value: 0.5, vsync: this, duration: Duration(milliseconds: 200));
    animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Container(
                padding: EdgeInsets.all(10),
                width: double.maxFinite,
                color: AppColorPallete.color,
                child: HeaderText(
                  "Chats",
                  align: TextAlign.left,
                  size: 40,
                ),
              ),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
          stream: ChatService.getChatListStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final docSnapshot = snapshot.data.documents;
              _updateChatList(snapshot.data.documentChanges);
              return FadeTransition(
                opacity: animation,
                child: IndexedStack(index: _currentIndex, children: <Widget>[
                  ListView.builder(
                      itemCount: docSnapshot.length,
                      itemBuilder: (context, index) {
                        return UserChatTile(docSnapshot[index],
                            hmap[docSnapshot[index].documentID], (uid) async {
                          _animationController.reset();
                          setState(() {
                            _currentIndex = _mapKeys.indexOf(uid) + 1;
                            hmap[uid].setView(true);
                            _animationController.forward();
                          });
                        });
                      }),
                  for (var item in _mapKeys) hmap[item]
                ]),
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
