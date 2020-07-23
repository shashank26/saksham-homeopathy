import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/blurred_image.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';

import 'constants.dart';

class NetworkOrFileImage extends StatefulWidget {
  final String _url;
  final String _blurredUrl;
  final String _fileName;
  bool raw;
  double height;
  double width;

  NetworkOrFileImage(this._url, this._blurredUrl, this._fileName,
      {double height, double width, bool raw = false}) {
    this.height = height;
    this.raw = raw;
    this.width = width;
  }

  @override
  _NetworkOrFileImageState createState() => _NetworkOrFileImageState();
}

class _NetworkOrFileImageState extends State<NetworkOrFileImage> {
  bool _loadBlurImage = true;

  @override
  void initState() {
    super.initState();
    _loadBlurImage = !FileHandler.instance.exists(widget._fileName);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.raw) {
      return Image.file(
                FileHandler.instance
              .getRawFile(widget._fileName),
                fit: BoxFit.fill,
                height: widget.height,
                width: widget.width,
              );
    }

    if (widget._blurredUrl != null &&
        widget._blurredUrl != '' &&
        _loadBlurImage) {
      return BlurredImage(widget._blurredUrl, () async {
        await FileHandler.instance.getFile(widget._url, widget._fileName);
        setState(() {
          _loadBlurImage = false;
        });
      });
    } else if (widget._fileName != '' &&
        widget._fileName != null &&
        widget._url != '' &&
        widget._url != null) {
      return StreamBuilder<File>(
          stream: FileHandler.instance
              .getFile(widget._url, widget._fileName)
              .asStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.file(
                snapshot.data,
                fit: BoxFit.fill,
                height: widget.height,
                width: widget.width,
              );
            }
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColorPallete.color),
            );
          });
    } else {
      return Container();
    }
  }
}
