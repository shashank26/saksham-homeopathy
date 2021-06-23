import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final Function callback;
  ImageSourceBottomSheet(this.callback);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      // height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0, horizontal: 10),
              child: MaterialButton(
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0, horizontal: 10),
              child: MaterialButton(
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
                      child: Text('Media'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 5.0, horizontal: 10),
              child: MaterialButton(
                elevation: 0,
                color: Colors.white,
                height: 50,
                onPressed: () {
                  callback(null);
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.cancel),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
