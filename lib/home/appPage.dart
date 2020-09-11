import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/home/chat/admin_chat_page.dart';
import 'package:saksham_homeopathy/home/admin_updates/admin_updates.dart';
import 'package:saksham_homeopathy/home/chat/chat_page.dart';
import 'package:saksham_homeopathy/home/history/historyPage.dart';
import 'package:saksham_homeopathy/home/profile/profilePage.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

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
  StreamController<bool> _isVisible = StreamController.broadcast();
  // List<int> _traversedIndexes = [];

  @override
  void initState() {
    super.initState();
    if (ChatService.unreadStreamController == null ||
        ChatService.unreadStreamController.isClosed) {
      ChatService.unreadStreamController = StreamController.broadcast();
    }
    _animationController = AnimationController(
        value: 0.5, vsync: this, duration: Duration(milliseconds: 200));
    animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    if (OTPAuth.isAdmin) {
      this.widgets = <Widget>[
        AdminUpdates(),
        AdminChatPage(),
        ProfilePage(),
      ];
    } else {
      FirestoreCollection.isWhiteListed(OTPAuth.currentUser.phoneNumber)
          .then((value) {
        if (value.documents.length > 0) {
          ChatService.getUserInfo(OTPAuth.adminId).listen((value) {
            setState(() {
              if (this.widgets.length == 0) {
                this.widgets = <Widget>[
                  AdminUpdates(),
                  ChatPage(new ChatService(OTPAuth.adminId),
                      ProfileInfo.fromMap(value.data), _isVisible.stream),
                  HistoryView(user: widget.user, uid: widget.user.uid),
                  ProfilePage(),
                ];
              } else {
                this.widgets[1] = ChatPage(new ChatService(OTPAuth.adminId),
                    ProfileInfo.fromMap(value.data), _isVisible.stream);
              }
            });
          });
        } else {
          setState(() {
            this.widgets = <Widget>[
              AdminUpdates(),
              Container(
                child: Center(
                  child: Align(
                    alignment: Alignment.center,
                      child: Text(
                    'Please subscribe or contact your doctor to access chat.',
                    style: TextStyle(
                      color: AppColorPallete.textColor,
                      fontSize: 16,
                    ),
                  )),
                ),
              ),
              HistoryView(user: widget.user, uid: widget.user.uid),
              ProfilePage(),
            ];
          });
        }
      });
      _isVisible.add(false);
    }
    _animationController.forward();
  }

  _navigate(index, {isPop = false}) {
    if (_currentIndex != index) {
      _animationController.reset();
      setState(() {
        _animationController.forward();
        _currentIndex = index;
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    super.dispose();
    ChatService.unreadStreamController.close();
    _isVisible.close();
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
          _isVisible.add(index == 1 && !OTPAuth.isAdmin);
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
                StreamBuilder<Map<String, bool>>(
                    stream: ChatService.unreadStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Visibility(
                          visible: snapshot.data.containsValue(true),
                          child: Positioned(
                              child: Container(
                                height: 28,
                                width: 28,
                                child: Material(
                                    borderRadius: BorderRadius.circular(14),
                                    color: AppColorPallete.color,
                                    elevation: 5,
                                    child: Icon(Icons.notifications_active,
                                        size: 20,
                                        color: _currentIndex == 1
                                            ? Colors.white
                                            : Colors.black.withOpacity(0.5))),
                              ),
                              right: 0,
                              top: 0),
                        );
                      }
                      return Text('');
                    })
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
