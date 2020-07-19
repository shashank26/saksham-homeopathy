import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class MessageBubble extends StatelessWidget {
  final MessageInfo info;
  final FirebaseUser user = OTPAuth.currentUser;

  MessageBubble(this.info);

  @override
  Widget build(BuildContext context) {
    final isMe = user.uid == this.info.sender;
    return Padding(
      padding: isMe ? EdgeInsets.only(left: 40) : EdgeInsets.only(right: 40),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(info.timeStamp.toString()),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: isMe ? Radius.circular(10) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: info.image != null && info.image != ''
                  ? NetworkOrFileImage(
                      info.image,
                      info.blurredImage,
                      info.fileName,
                    )
                  : Text(
                      info.message,
                      textAlign: TextAlign.right,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
