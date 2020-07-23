import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/home/add_post.dart';
import 'package:saksham_homeopathy/home/profile_avatar.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: OTPAuth.isAdmin ? FloatingActionButton(
        onPressed: () async {
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
                  body: AddPost(context)));
        },
        child: Icon(
          Icons.cloud_upload,
          color: Colors.white,
        ),
        backgroundColor: AppColorPallete.color,
      ) : null,
      appBar: AppBar(
        title: Container(
            width: double.maxFinite,
            color: AppColorPallete.color,
            child: HeaderText(
              "Updates",
              align: TextAlign.left,
              size: 40,
            )),
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
                            padding: EdgeInsets.only(bottom: 40),
                            width: MediaQuery.of(context).size.width,
                            child: Material(
                              elevation: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Material(
                                          color: AppColorPallete.color,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          elevation: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                _post.timeStamp.toString()),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: OTPAuth.isAdmin,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () {
                                            _deleteConfirmDialog(snapshot.data
                                                .documents[index].reference);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  Material(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RichText(
                                        text: TextSpan(
                                            text: _post.text,
                                            style: TextStyle(
                                                color: Colors.grey[850])),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !noe(_post.imageUrl),
                                    child: 
                                         NetworkOrFileImage(
                                          _post.imageUrl,
                                          null,
                                          _post.imageName,
                                        ),
                                  )
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
