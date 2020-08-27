import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/image_source_bottom_sheet.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
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
  bool _addLink = false;
  ImageSource _imageSource;
  final _postText = TextEditingController(text: '');
  final _href = TextEditingController(text: '');

  @override
  initState() {
    super.initState();
    if (widget._post == null) {
      _post = AdminPost();
      return;
    }
    _post = AdminPost.fromMap(widget._post.data);
    _postText.text = _post.text;
    if (!noe(_post.imageUrl)) {
      FileHandler.instance
          .getFile(_post.imageUrl, _post.imageName)
          .then((value) {
        setState(() {
          _post.image = value;
        });
      });
    }
  }

  _postUpdate() async {
    try {
      Navigator.pop(context);
      Scaffold.of(widget._parContext)
          .showSnackBar(SnackBar(content: Text('Posting...')));
      _post.text = _postText.text.trim();
      _post.href = _href.text;
      _post.timeStamp = DateTime.now();
      if (_post.image != null) {
        await FileHandler.instance.uploadPostImage(_post);
      }
      if (widget._post != null) {
        widget._post.reference.updateData(AdminPost.toMap(_post));
      } else {
        await FirestoreCollection.postUpdate.add(AdminPost.toMap(_post));
      }
      _post = new AdminPost();
      _href.text = '';
      _postText.text = '';
      Scaffold.of(widget._parContext)
          .showSnackBar(SnackBar(content: Text('Post Successful')));
    } on Exception catch (e) {
      Scaffold.of(widget._parContext)
          .showSnackBar(SnackBar(content: Text('Post failed to upload.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: EdgeInsets.all(5),
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.image,
                      color: AppColorPallete.color,
                    ),
                    onPressed: () async {
                      await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withOpacity(0.5),
                          context: context,
                          builder: (builder) =>
                              ImageSourceBottomSheet((ImageSource imageSource) {
                                _imageSource = imageSource;
                              }));
                      if (_imageSource != null) {
                        final File image =
                            await CImagePicker.getImage(_imageSource);
                        setState(() {
                          _post.image = image;
                          _post.imageName = ImagePath.imagePostPath();
                        });
                      }
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.link, color: AppColorPallete.color),
                  //   onPressed: () {
                  //     setState(() {
                  //       _addLink = !_addLink;
                  //     });
                  //   },
                  // )
                ],
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
                maxLength: 200,
              ),
              Visibility(
                visible: _addLink,
                child: TextField(
                  controller: _href,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.link),
                    labelText: 'Add a link',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  maxLines: null,
                  minLines: 2,
                  maxLength: 300,
                ),
              ),
              if (_post.image != null)
                Material(
                  elevation: 10,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: NetworkOrFileImage(
                          null,
                          null,
                          _post.image.path,
                          raw: true,
                          height: 200,
                          width: 200,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  // size: 25,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  FileHandler.instance.deleteRaw(_post.image);
                                  setState(() {
                                    _post.image = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              FlatButton(
                color: AppColorPallete.color,
                onPressed: () async {
                  if (noe(_post.imageName) &&
                      noe(_postText.text) &&
                      noe(_href.text)) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Please add an image, link or post"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red[600],
                    ));
                    return;
                  }
                  await _postUpdate();
                },
                child: Text(
                  widget._post == null ? 'Post' : 'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
