import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/constants.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final Function callback;
  ImageSourceBottomSheet(this.callback);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorPallete.color,
      height: 102,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MaterialButton(
              elevation: 0,
              color: Colors.white,
              height: 50,
              onPressed: () {
                callback(ImageSource.camera);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.camera_alt),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Camera'),
                  ),
                ],
              ),
            ),
            MaterialButton(
              elevation: 0,
              color: Colors.white,
              height: 50,
              onPressed: () {
                callback(ImageSource.gallery);
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.photo),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Images'),
                  ),
                ],
              ),
            )
          ],
        ),
    );
  }
}
