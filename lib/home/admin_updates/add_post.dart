import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/image_source_bottom_sheet.dart';
import 'package:saksham_homeopathy/home/admin_updates/file_view.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/image_picker.dart';

class AddPost extends StatefulWidget {
  final _parContext;
  final DocumentSnapshot _post;
  AddPost(this._parContext, this._post);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  AdminPost _post;
  ImageSource _imageSource;
  final _postText = TextEditingController(text: '');
  final _videoTitle = TextEditingController(text: '');
  final isMP4Video = (File file) => file.path.endsWith('.mp4');
  MediaType selectedMediaType;
  // bool _showDialog = false;
  // String _progressionText = '';

  @override
  initState() {
    super.initState();

    if (widget._post == null) {
      _post = AdminPost();
      return;
    }
    _post = AdminPost.fromMap(widget._post.data());
    _postText.text = _post.text;
  }

  _showDialog(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(text);
        });
  }

  _hideDialog() {
    Navigator.pop(context);
  }

  _postUpdate({bool isTestimonial = false}) async {
    try {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Posting...'),
        duration: Duration(seconds: 1),
      ));
      if (_post.file != null) {
        // if (isMP4Video(_post.file)) {
        //   _showDialog('Compressing video...');
        //   _post.file = await FileHandler.instance.compressMP4File(_post.file);
        //   _hideDialog();
        // }
        _showDialog('Uploading...');
        _post =
            await FileHandler.instance.uploadPostFile(_post, selectedMediaType);
        _hideDialog();
      }
      await _postUpdateAfterUpload(isTestimonial: isTestimonial);
    } on DetailedApiRequestError catch (d) {
      if (d.message.contains('quota'))
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('You have exceeded quota of 6 videos per day.')));
      else
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Post failed to upload.')));
      _hideDialog();
    } on Exception catch (e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Post failed to upload.')));
      _hideDialog();
    }
  }

  _postUpdateAfterUpload({bool isTestimonial = false}) async {
    _showDialog('Posting...');
    _post.timeStamp = DateTime.now();
    if (widget._post != null) {
      widget._post.reference.update(AdminPost.toMap(_post));
    } else {
      if (isTestimonial) {
        await FirestoreCollection.postTestimonial.add(AdminPost.toMap(_post));
      } else {
        await FirestoreCollection.postUpdate.add(AdminPost.toMap(_post));
      }
    }
    _hideDialog();
    Navigator.pop(context);
    Scaffold.of(widget._parContext)
        .showSnackBar(SnackBar(content: Text('Post Successful')));
  }

  _pickMedia(MediaType mediaType) async {
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        context: context,
        builder: (builder) => ImageSourceBottomSheet((ImageSource imageSource) {
              _imageSource = imageSource;
            }));

    if (_imageSource != null) {
      File media;
      switch (mediaType) {
        case MediaType.IMAGE:
          media = await CImagePicker.getImage(_imageSource);
          break;
        case MediaType.VIDEO:
          media = await CImagePicker.getVideo(_imageSource);
          if (media != null && !media.path.endsWith('.mp4')) {
            media = await media.rename('${media.path}.mp4');
          }
          break;
      }
      if (media != null) {
        setState(() {
          _post.file = media;
        });
      }
    }
  }

  Future<String> _getMediaLink() async {
    final link = await showDialog<String>(
        context: context,
        builder: (context) {
          String link = '';
          return Material(
            child: Container(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeaderText(
                    'Paste a youtube link here!',
                    size: 16,
                  ),
                  TextField(
                    onChanged: (val) {
                      link = val;
                    },
                  ),
                  Wrap(
                    spacing: 10,
                    children: [
                      FlatButton(
                          color: AppColorPallete.color,
                          onPressed: () {
                            Navigator.pop(context, link);
                          },
                          child: Text(
                            'Ok',
                            style: TextStyle(color: Colors.white),
                          )),
                      FlatButton(
                          color: AppColorPallete.color,
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          child: Text(
                            'Cancel',
                          ))
                    ],
                  ),
                ],
              ),
            ),
          );
        });
    try {
      final filters = ['//www.youtube.com/watch?v=', '//youtu.be/'];
      if (!noe(link) && filters.any((f) => link.contains(f))) {
        final filter = filters.where((f) => link.contains(f)).first;
        return link.split(filter)[1].substring(0, 11);
      }
    } on Exception catch (e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Url is not valid!')));
    }
  }

  isPostValid() {
    final sb = (e) => Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[600],
        ));
    if (noe(_post.text) && _post.file == null) {
      sb('Please add a post or any media.');
      return false;
    }
    if (_post.file != null && isMP4Video(_post.file) && noe(_post.fileName)) {
      sb('Please add a title to the video.');
      return false;
    }
    return true;
  }

  isTestimonialValid() {
    final sb = (e) => Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[600],
        ));
    if (noe(_post.text) || _post.file == null || noe(_post.fileName)) {
      sb('Please add a post and a video with a title.');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (widget._post == null)
                Wrap(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.photo_library,
                        color: AppColorPallete.color,
                      ),
                      onPressed: () async {
                        await _pickMedia(MediaType.IMAGE);
                        selectedMediaType = MediaType.IMAGE;
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.videocam,
                        color: AppColorPallete.color,
                      ),
                      onPressed: () async {
                        await _pickMedia(MediaType.VIDEO);
                        selectedMediaType = MediaType.VIDEO;
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.link,
                        color: AppColorPallete.color,
                      ),
                      onPressed: () async {
                        final link = await _getMediaLink();
                        if (!noe(link)) {
                          File thumbnail = await FileHandler.instance.getFile(
                              YoutubeApiConstants.thumbnail(link),
                              'thumbnail.png',
                              replace: true);
                          selectedMediaType = MediaType.LINK;
                          setState(() {
                            _post.file = thumbnail;
                            _post.fileName = link;
                            _post.fileUrl = link;
                            _post.videoThumbnail = link;
                          });
                        }
                      },
                    ),
                  ],
                ),
              if (widget._post == null)
                Visibility(
                  visible: _post.file != null,
                  child: FileView(_post.file, () async {
                    if (widget._post != null) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Deleting file from cloud.'),
                      ));
                      await FileHandler.instance
                          .deleteCloudFile(_post.fileName);
                      if (_post.fileName.endsWith('.mp4')) {
                        await FileHandler.instance
                            .deleteCloudFile(_post.fileName + '.png');
                      }
                    }
                    setState(() {
                      _post.file = null;
                      _post.fileName = null;
                      _post.fileUrl = null;
                      _post.videoThumbnail = null;
                    });
                  }),
                ),
              TextField(
                controller: _postText,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.text_fields),
                  labelText: 'Write something...',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                maxLines: null,
                minLines: 2,
                onChanged: (val) {
                  _post.text = val;
                },
              ),
              if (widget._post == null)
                Visibility(
                  visible: _post.file != null && isMP4Video(_post.file),
                  child: TextField(
                    // controller: _videoTitle,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.text_fields),
                      labelText: 'Give a title for video...',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    maxLines: null,
                    minLines: 2,
                    onChanged: (val) {
                      _post.fileName = val;
                    },
                  ),
                ),
              Wrap(
                spacing: 10,
                children: [
                  FlatButton(
                    color: AppColorPallete.color,
                    onPressed: () async {
                      if (isPostValid()) {
                        await _postUpdate();
                      }
                    },
                    child: Text(
                      widget._post == null ? 'Post' : 'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (widget._post == null)
                    FlatButton(
                      color: AppColorPallete.color,
                      onPressed: () async {
                        if (isTestimonialValid()) {
                          await _postUpdate(isTestimonial: true);
                        }
                      },
                      child: Text(
                        'Testimonial',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadStateTemp with ChangeNotifier, DiagnosticableTreeMixin {
  double _uploaded;
  double get uploaded => _uploaded;

  void setUploadedStatus(double val) {
    _uploaded = val;
    notifyListeners();
  }

  double _compressed;
  double get compressed => _compressed;

  void setCompressedStatus(double val) {
    _compressed = val;
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('uploaded', uploaded));
  }
}
