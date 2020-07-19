import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';

class UserChatTile extends StatefulWidget {
  final DocumentSnapshot _documentSnapshot;
  final Widget _userInfoWidgets;
  final Function _tappedWidgetIndex;
  UserChatTile(this._documentSnapshot, this._userInfoWidgets, this._tappedWidgetIndex);
  @override
  _UserChatTileState createState() => _UserChatTileState();
}

class _UserChatTileState extends State<UserChatTile> {
  ProfileInfo _profileInfo;

  @override
  initState() {
    super.initState();
  }

  // _openChat(String uid) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return widget._userInfoWidgets[0];
  //       });
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: ChatService.getUserInfo(widget._documentSnapshot.documentID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _profileInfo = ProfileInfo.fromMap(snapshot.data.data);
            return Material(
              elevation: 5,
              child: InkWell(
                onTap: () {
                  // _openChat(widget._documentSnapshot.documentID);
                  widget._tappedWidgetIndex(widget._documentSnapshot.documentID);
                },
                child: Container(
                  height: 80,
                  padding: EdgeInsets.all(10),
                  child: Row(
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            HeaderText(
                              _profileInfo.displayName,
                              size: 15,
                            ),
                            LatestMessage(widget._documentSnapshot)
                          ],
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: ChatService.unreadMessageStream(
                            widget._documentSnapshot.reference),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data.documents.length > 0) {
                            return Expanded(
                              child: Align(
                                alignment: FractionalOffset.centerRight,
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: Material(
                                    elevation: 5,
                                    borderRadius: BorderRadius.circular(15),
                                    color: AppColorPallete.color,
                                    child: Center(
                                      child: Text(
                                        snapshot.data.documents.length.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else
            return Container();
        });
  }
}

class LatestMessage extends StatefulWidget {
  final DocumentSnapshot _documentSnapshot;
  LatestMessage(this._documentSnapshot);
  @override
  _LatestMessageState createState() => _LatestMessageState();
}

class _LatestMessageState extends State<LatestMessage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: ChatService.getLatestMessageStream(
            widget._documentSnapshot.reference),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.documents.length > 0) {
            final info = MessageInfo.fromMap(snapshot.data.documents[0].data);
            if (info.image != null) {
              return Row(
                children: <Widget>[
                  Icon(
                    Icons.image,
                    color: AppColorPallete.textColor,
                  ),
                  Text(
                    'Photo',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              );
            } else {
              return Text(
                  info.message.length > 20
                      ? info.message.substring(0, 20) + '...'
                      : info.message,
                  style: TextStyle(fontStyle: FontStyle.italic));
            }
          }
          return Container();
        });
  }
}
