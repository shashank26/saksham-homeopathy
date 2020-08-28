import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/home/admin_updates/add_post.dart';
import 'package:saksham_homeopathy/home/profile/profile_avatar.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminUpdates extends StatefulWidget {
  @override
  _AdminUpdatesState createState() => _AdminUpdatesState();
}

class _AdminUpdatesState extends State<AdminUpdates> {
  _deleteConfirmDialog(DocumentReference ref) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: HeaderText('Delete'),
            content: Text(
              'Delete this post?',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.redAccent,
                child: Text('Delete'),
                onPressed: () async {
                  showDialog(
                      context: context, child: CustomDialog('Deleting...'));
                  await ref.delete();
                  int count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 2;
                  });
                },
              ),
              FlatButton(
                textColor: Colors.black,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  _addOrEditPost({DocumentSnapshot post}) async {
    await showDialog(
        context: context,
        child: Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              title: HeaderText(
                'Add Post',
                size: 40,
              ),
            ),
            body: AddPost(context, post)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            width: double.maxFinite,
            color: AppColorPallete.color,
            child: HeaderText(
              "Updates",
              align: TextAlign.left,
              size: 40,
            )),
        actions: [
          if (OTPAuth.isAdmin)
            FlatButton(
                onPressed: () async {
                  await _addOrEditPost();
                },
                child: Container(
                  child: Icon(
                    Icons.cloud_upload,
                    color: AppColorPallete.textColor,
                    size: 40,
                  ),
                ))
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Material(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProfileAvatar(OTPAuth.adminId),
                )),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreCollection.adminUpdates.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.documents.length > 0) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        print('load more...');
                      },
                      child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          final _post = AdminPost.fromMap(
                              snapshot.data.documents[index].data);
                          return Container(
                            padding: EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width,
                            child: Material(
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Material(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Linkify(
                                          onOpen: (link) async {
                                            if (await canLaunch(link.url)) {
                                              await launch(link.url);
                                            } else {
                                              // throw 'Could not launch ${link.url}';
                                            }
                                          },
                                          text: _post.text,
                                          style: TextStyle(
                                              color: AppColorPallete.textColor)),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !noe(_post.imageUrl),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Scaffold(
                                                appBar: AppBar(),
                                                body: Container(
                                                  child: PhotoView(
                                                      imageProvider: FileImage(
                                                          FileHandler.instance
                                                              .getRawFile(
                                                                  fileName: _post
                                                                      .imageName))),
                                                ),
                                              );
                                            });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        child: NetworkOrFileImage(
                                          _post.imageUrl,
                                          null,
                                          _post.imageName,
                                          height: 300,
                                          width: 300,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          color: Colors.grey.shade300,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              _post.getTimestamp(),
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: OTPAuth.isAdmin,
                                        child: Container(
                                          child: PopupMenuButton(
                                              onSelected: (value) async {
                                            switch (value) {
                                              case PopupMenuValues.DELETE:
                                                await _deleteConfirmDialog(
                                                    snapshot
                                                        .data
                                                        .documents[index]
                                                        .reference);
                                                break;
                                              case PopupMenuValues.EDIT:
                                                await _addOrEditPost(
                                                  post: snapshot
                                                      .data.documents[index],
                                                );
                                                break;
                                              default:
                                            }
                                          }, itemBuilder: (context) {
                                            return [
                                              PopupMenuItem(
                                                value: PopupMenuValues.EDIT,
                                                child:
                                                    Center(child: Text('Edit')),
                                              ),
                                              PopupMenuItem(
                                                value: PopupMenuValues.DELETE,
                                                child: Center(
                                                    child: Text('Delete')),
                                              ),
                                            ];
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Center(
                      child: HeaderText('No Updates'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PopupMenuValues {
  DELETE,
  EDIT,
}
