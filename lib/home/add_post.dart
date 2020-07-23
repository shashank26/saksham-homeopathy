import 'dart:io';

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
  AddPost(this._parContext);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  AdminPost _post = AdminPost();
  bool _addLink = false;
  ImageSource _imageSource = ImageSource.camera;
  final _postText = TextEditingController(text: '');
  final _href = TextEditingController(text: '');

  _postUpdate() async {
    try {
      Navigator.pop(context);
      Scaffold.of(widget._parContext)
          .showSnackBar(SnackBar(content: Text('Posting...')));
      _post.text = _postText.text.trim();
      _post.href = _href.text;
      _post.timeStamp = DateTime.now();
      if (_post.image != null)
        await FileHandler.instance.uploadPostImage(_post);
      await FirestoreCollection.postUpdate.add(AdminPost.toMap(_post));
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
                          context: context,
                          builder: (builder) =>
                              ImageSourceBottomSheet((ImageSource imageSource) {
                                _imageSource = imageSource;
                              }));
                      final File image =
                          await CImagePicker.getImage(_imageSource);
                      setState(() {
                        _post.image = image;
                        _post.imageName = ImagePath.imagePostPath();
                      });
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
                  'Post',
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
