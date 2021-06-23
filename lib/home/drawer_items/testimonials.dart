import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Testimonials extends StatefulWidget {
  @override
  _TestimonialsState createState() => _TestimonialsState();
}

class _TestimonialsState extends State<Testimonials> {
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

  _getVideoPreview(AdminPost _post) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: Stack(
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
      ),
    );
  }

  _deleteConfirmDialog(DocumentReference ref, AdminPost _post) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: HeaderText('Delete'),
            content: Text(
              'Delete this testimonial?',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.redAccent,
                child: Text('Delete'),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (_) => CustomDialog('Deleting...'));
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColorPallete.color,
        appBar: AppBar(
          iconTheme: IconThemeData(color: AppColorPallete.textColor),
          backgroundColor: AppColorPallete.backgroundColor,
          title: Container(
              color: AppColorPallete.backgroundColor,
              child: HeaderText(
                "Testimonials",
                align: TextAlign.left,
                size: 20,
              )),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreCollection.testimonials(
                          this.batch * this.batchSize)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data.docs.length > 0) {
                      this.countOfPosts = snapshot.data.docs.length;
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          final _post = AdminPost.fromMap(
                              snapshot.data.docs[index].data());
                          return Container(
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width,
                            child: Material(
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(0),
                                    child: Builder(
                                        builder: (_) =>
                                            _getVideoPreview(_post)),
                                  ),
                                  Material(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(_post.text,
                                          style: TextStyle(
                                              color: AppColorPallete.textColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500)),
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
                                                    snapshot.data.docs[index]
                                                        .reference,
                                                    _post);

                                                break;
                                              default:
                                            }
                                          }, itemBuilder: (context) {
                                            return [
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
                        child: HeaderText('Coming soon...'),
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
      ),
    );
  }
}
