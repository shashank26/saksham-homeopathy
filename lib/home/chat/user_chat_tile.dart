import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/home/chat/chat_page.dart';
import 'package:saksham_homeopathy/home/chat/lastest_message.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';

class UserChatTile extends StatefulWidget {
  final String uid;
  final CollectionReference _chatRef;
  final Function(String, ProfileInfo) _callback;
  UserChatTile(this.uid, this._chatRef, this._callback);
  @override
  _UserChatTileState createState() => _UserChatTileState();
}

class _UserChatTileState extends State<UserChatTile> {
  ProfileInfo _profileInfo;
  List<MessageInfo> _messages = [];
  String latestMessage = '';

  @override
  initState() {
    super.initState();
    // _messages.addAll(FileHandler.instance.getChatFileData(widget.uid));
  }

  _openChat() {
  showDialog(
      context: context,
      builder: (BuildContext bc) {
        return ChatPage(ChatService(widget.uid),  _profileInfo, null, whitelisted : true);
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      child: InkWell(
        onTap: () {
          // _openChat(widget.uid);
          _openChat();
        },
        child: Container(
          height: 80,
          width: double.maxFinite,
          padding: EdgeInsets.all(10),
          child: StreamBuilder<DocumentSnapshot>(
              stream: ChatService.getUserInfo(widget.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _profileInfo = ProfileInfo.fromMap(snapshot.data.data());
                  widget._callback(widget.uid, _profileInfo);
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                        child: ClipOval(
                          child: NetworkOrFileImage(
                            _profileInfo.photoUrl,
                            null,
                            _profileInfo.fileName,
                            height: double.maxFinite,
                            width: double.maxFinite,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                noe(_profileInfo.displayName) ? _profileInfo.phoneNumber : _profileInfo.displayName,
                                style: TextStyle(color: AppColorPallete.textColor, fontSize: 18),
                              ),
                              LatestMessage(FirestoreCollection.latestMessage(
                                  widget.uid), widget.uid),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              }),
        ),
      ),
    );
  }
}
