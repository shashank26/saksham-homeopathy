import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'constants.dart';
import 'header_text.dart';

final imageSwipeView = (context, currentIndex, images, title) => showDialog(
    context: context,
    builder: (context) {
      PageController ctrl = PageController(initialPage: currentIndex);
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
          iconTheme: IconThemeData(color: AppColorPallete.textColor),
          backgroundColor: AppColorPallete.backgroundColor,
          title: Container(
              color: AppColorPallete.backgroundColor,
              child: HeaderText(
                title,
                align: TextAlign.left,
                size: 20,
              )),
        ),
          body: PhotoViewGallery(
            pageOptions: <PhotoViewGalleryPageOptions>[
              for (var i = 0; i < images.length; i++)
                PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(images[i])),
                ),
            ],
            pageController: ctrl,
          ),
        ),
      );
    });
