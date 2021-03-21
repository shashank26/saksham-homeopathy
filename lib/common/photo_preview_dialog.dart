import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';

import 'constants.dart';

final previewPhoto =
    (context, fileName) => showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColorPallete.backgroundColor,
              iconTheme: IconThemeData(color: AppColorPallete.textColor),
            ),
            body: Container(
              child: PhotoView(
                  imageProvider: FileImage(
                      FileHandler.instance.getRawFile(fileName: fileName))),
            ),
          );
        });
