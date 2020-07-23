import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/home/admin_chat_page.dart';
import 'package:saksham_homeopathy/home/admin_updates.dart';
import 'package:saksham_homeopathy/home/historyPage.dart';
import 'package:saksham_homeopathy/home/profilePage.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

import 'chat_page.dart';

class AppPage extends StatefulWidget {
  final FirebaseUser user = OTPAuth.currentUser;

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  AnimationController _animationController;
  Animation<double> animation;
  List<Widget> widgets = [];
  Stream unreadMessages;
  // List<int> _traversedIndexes = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        value: 0.5, vsync: this, duration: Duration(milliseconds: 200));
    animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    if (OTPAuth.isAdmin) {
      this.widgets = <Widget>[
        AdminUpdates(),
        AdminChatPage(),
        ProfilePage(widget.user),
      ];
    } else {
      this.widgets = <Widget>[
        AdminUpdates(),
        ChatPage(OTPAuth.adminId),
        HistoryView(user: widget.user, uid: widget.user.uid),
        ProfilePage(widget.user),
      ];
    }
    _animationController.forward();

    if (OTPAuth.isAdmin) {
      unreadMessages = ChatService.initializeUnreadMessageStream();
    } else {
      unreadMessages = ChatService.initializeUnreadMessageStream(
          documentReference:
              (this.widgets[1] as ChatPage).chatService.chatRef.parent());
    }
  }

  _navigate(index, {isPop = false}) {
    _animationController.reset();
          setState(() {
            _animationController.forward();
            _currentIndex = index;
            // if (!isPop){
            //   _traversedIndexes.add(_currentIndex);
            // }
            if (!OTPAuth.isAdmin) {
              (this.widgets[1] as ChatPage).setView(_currentIndex == 1);
            }
          });
  }

  @override
  void dispose() {
    super.dispose();
    ChatService.unreadChats.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: animation,
        child: WillPopScope(
          onWillPop: () async {
            if (_currentIndex != 0) {
              _navigate(0);
              return false;
            }
            return true;
            // if (_traversedIndexes.length == 0) {
            //   return true;
            // } else {
            //   _navigate(_traversedIndexes.removeAt(0), isPop : true);
            //   return false;
            // }
          },
          child: IndexedStack(
            index: _currentIndex,
            children: widgets,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 5,
        currentIndex: _currentIndex,
        onTap: (int index) {
          _navigate(index);
        },
        iconSize: 40,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(Icons.chat),
                StreamBuilder<int>(
                  stream: ChatService.unreadChats.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data > 0)
                      return Positioned(
                          child: Container(
                            height: 24,
                            width: 24,
                            child: Material(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColorPallete.color,
                              elevation: 5,
                              child: Center(
                                child: Text(snapshot.data.toString()),
                              ),
                            ),
                          ),
                          right: 0,
                          top: 0);
                    else
                      return Text('');
                  },
                ),
              ],
            ),
            title: Text('Chat'),
          ),
          if (!OTPAuth.isAdmin)
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              title: Text('History'),
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
