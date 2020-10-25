import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/expandable_text.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/home/admin_updates/add_post.dart';
import 'package:saksham_homeopathy/home/admin_updates/app_drawer.dart';
import 'package:saksham_homeopathy/home/profile/preview_profile.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AdminUpdates extends StatefulWidget {
  @override
  _AdminUpdatesState createState() => _AdminUpdatesState();
}

class _AdminUpdatesState extends State<AdminUpdates> {
  
  int batch = 1;
  int batchSize = 20;
  final scrollController = new ScrollController();
  bool showLoadMoreOption = false;
  int countOfPosts = 0;

  @override
  initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent - 20 &&
          !showLoadMoreOption &&
          countOfPosts == batch * batchSize) {
        setState(() {
          showLoadMoreOption = true;
        });
      } else if (scrollController.offset <
              scrollController.position.maxScrollExtent - 20 &&
          showLoadMoreOption) {
        setState(() {
          showLoadMoreOption = false;
        });
      }
    });
  }

  _deleteConfirmDialog(DocumentReference ref, AdminPost _post) {
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
                  if (!noe(_post.fileName) && noe(_post.videoThumbnail)) {
                    await FileHandler.instance.deleteCloudFile(_post.fileName);
                  }
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
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UploadStateTemp()),
          ],
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColorPallete.backgroundColor,
                iconTheme: IconThemeData(color: AppColorPallete.textColor),
                title: HeaderText(
                  'Add Post',
                  size: 40,
                ),
              ),
              body: AddPost(context, post)),
        ));
  }

  _previewProfile(ProfileInfo info) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return PreviewProfile(info);
        });
  }

  _getVideoPreview(AdminPost _post) {
    return Stack(
      children: [
        NetworkOrFileImage(
          YoutubeApiConstants.thumbnail(_post.videoThumbnail),
          null,
          null,
          width: MediaQuery.of(context).size.width,
          height: 300,
        ),
        Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () async {
                final androidInfo = await DeviceInfoPlugin().androidInfo;
                final sdkInt = androidInfo.version.sdkInt;
                if (sdkInt < 20) {
                  await launch(YoutubeApiConstants.embedUrl(_post.fileUrl));
                  return;
                }
                Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      YoutubePlayerController _controller =
                          YoutubePlayerController(
                        initialVideoId: _post.fileUrl,
                        flags: YoutubePlayerFlags(
                          autoPlay: true,
                          mute: false,
                        ),
                      );
                      return YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: false,
                        progressIndicatorColor: AppColorPallete.color,
                        onReady: () {
                          _controller.addListener(() {});
                        },
                      );
                    }));
              },
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPallete.color,
      drawer: AppDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColorPallete.textColor),
        backgroundColor: AppColorPallete.backgroundColor,
        title: Container(
            color: AppColorPallete.backgroundColor,
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
              ),
            ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreCollection.adminUpdates(
                        this.batch * this.batchSize)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.documents.length > 0) {
                    this.countOfPosts = snapshot.data.documents.length;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        final _post = AdminPost.fromMap(
                            snapshot.data.documents[index].data);
                        return Container(
                          padding: EdgeInsets.all(5),
                          width: MediaQuery.of(context).size.width,
                          child: Material(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Material(
                                  child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: ExpandableText(_post.text)),
                                ),
                                Visibility(
                                  visible: !noe(_post.fileName),
                                  child: Container(
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                    child: noe(_post.fileName)
                                        ? Container()
                                        : !noe(_post.videoThumbnail)
                                            ? _getVideoPreview(_post)
                                            : GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Scaffold(
                                                          appBar: AppBar(
                                                            backgroundColor:
                                                                AppColorPallete
                                                                    .backgroundColor,
                                                            iconTheme: IconThemeData(
                                                                color: AppColorPallete
                                                                    .textColor),
                                                          ),
                                                          body: Container(
                                                            child: PhotoView(
                                                                imageProvider: FileImage(FileHandler
                                                                    .instance
                                                                    .getRawFile(
                                                                        fileName:
                                                                            _post.fileName))),
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: NetworkOrFileImage(
                                                  _post.fileUrl,
                                                  null,
                                                  _post.fileName,
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
                                                  snapshot.data.documents[index]
                                                      .reference,
                                                  _post);
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
                                              child: Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color: AppColorPallete
                                                        .textColor),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: PopupMenuValues.DELETE,
                                              child: Text('Delete',
                                                  style: TextStyle(
                                                      color: AppColorPallete
                                                          .textColor)),
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
                    );
                  } else {
                    return Center(
                      child: HeaderText('No Updates'),
                    );
                  }
                },
              ),
            ),
            Visibility(
              visible: showLoadMoreOption,
              child: Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: MaterialButton(
                    color: AppColorPallete.backgroundColor,
                    elevation: 10,
                    onPressed: () {
                      if (batch * batchSize <= countOfPosts) {
                        setState(() {
                          this.batch++;
                        });
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('There are no more posts.')));
                      }
                    },
                    child: HeaderText(
                      'Load Older Posts',
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}