import 'package:flutter/material.dart';
import 'image_source_bottom_sheet.dart';

final pickImageSource = (context, callback) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => ImageSourceBottomSheet(callback));