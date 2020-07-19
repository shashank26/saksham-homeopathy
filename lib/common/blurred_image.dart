import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class BlurredImage extends StatefulWidget {
  final String _url;
  final _callBack;
  BlurredImage(this._url, this._callBack);

  @override
  _BlurredImageState createState() => _BlurredImageState();
}

class _BlurredImageState extends State<BlurredImage> {
  bool _startDownload = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: NetworkImage(widget._url), fit: BoxFit.cover),
            ),
          ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          if (_startDownload)
            Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColorPallete.color),
                ),
              ),
            ),
          Center(
            child: Material(
              elevation: 5,
              shadowColor: Colors.black,
              color: AppColorPallete.color,
              borderRadius: BorderRadius.circular(50),
              child: IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.file_download,
                ),
                color: AppColorPallete.textColor,
                onPressed: () {
                  setState(() {
                    _startDownload = true;
                  });
                  widget._callBack();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
