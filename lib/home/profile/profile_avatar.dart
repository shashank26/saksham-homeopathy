import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';

class ProfileAvatar extends StatefulWidget {
  final String uid;
  final bool showName;
  final double radius;
  ProfileAvatar(this.uid, {this.showName = true, this.radius = 15});

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: ChatService.getUserInfo(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final _profileInfo = ProfileInfo.fromMap(snapshot.data.data());
            return Row(
              children: <Widget>[
                CircleAvatar(
                  radius: widget.radius,
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
                if (widget.showName)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        HeaderText(_profileInfo.displayName, size: 15),
                        // Text(
                        //   'Online',
                        //   style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        // )
                      ],
                    ),
                  ),
              ],
            );
          } else {
            return Container();
          }
        });
  }
}
