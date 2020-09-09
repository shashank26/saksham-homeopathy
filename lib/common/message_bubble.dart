import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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
          Text(info.getMessageTimestamp()),
          Container(
            height: 2,
          ),
          Container(
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: isMe ? Radius.circular(10) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(10),
              ),
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      info.image != null && info.image != ''
                          ? GestureDetector(
                              onTap: () {
                                if (FileHandler.instance
                                    .exists(fileName: info.fileName)) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Scaffold(
                                          appBar: AppBar(
                                            backgroundColor: AppColorPallete.backgroundColor,
                                            iconTheme: IconThemeData(color: AppColorPallete.textColor),
                                          ),
                                          body: Container(
                                            child: PhotoView(
                                                imageProvider: FileImage(
                                                    FileHandler
                                                        .instance
                                                        .getRawFile(
                                                            fileName: info
                                                                .fileName))),
                                          ),
                                        );
                                      });
                                }
                              },
                              child: NetworkOrFileImage(
                                info.image,
                                info.blurredImage,
                                info.fileName,
                                height: 300,
                                width: 300,
                              ),
                            )
                          : Linkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                }
                              },
                              text: info.message,
                              style: TextStyle(
                                fontSize: 18
                              ),
                            ),
                      if (info.sender == user.uid)
                        Container(
                          width: 0,
                          height: 5,
                        ),
                      if (info.sender == user.uid)
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: info.isRead
                              ? AppColorPallete.color
                              : AppColorPallete.textColor,
                        ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
