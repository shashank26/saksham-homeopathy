import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class LatestMessage extends StatefulWidget {
  final Stream<QuerySnapshot> latestMessageStream;
  final String chatId;
  static Map<String, bool> unreadMessage = Map<String, bool>();
  LatestMessage(this.latestMessageStream, this.chatId);

  @override
  _LatestMessageState createState() => _LatestMessageState();
}

class _LatestMessageState extends State<LatestMessage> {

  bool isUnread(MessageInfo info) => info.sender != OTPAuth.currentUser.uid && !info.isRead;

  void updateUnreadChats(MessageInfo info) {
    bool unread = isUnread(info);
    LatestMessage.unreadMessage
        .update(widget.chatId, (value) => unread, ifAbsent: () => unread);
    ChatService.unreadStreamController.add(LatestMessage.unreadMessage);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: this.widget.latestMessageStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.docs.length > 0) {
            MessageInfo info =
                MessageInfo.fromMap(snapshot.data.docs[0].data());
            updateUnreadChats(info);
            bool unread = isUnread(info);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 30,
                  child: Wrap(
                    children: <Widget>[
                      if (!noe(info.image)) Icon(Icons.image),
                      Text(
                        !noe(info.image)
                            ? 'Image'
                            : info.message.length > 30
                                ? info.message.substring(0, 30) + '...'
                                : info.message,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    height: 28,
                    width: 28,
                    child: Material(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColorPallete.color,
                      elevation: 5,
                      child: Center(
                        child: Icon(Icons.notifications_active,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          }
          return Text('');
        });
  }
}
