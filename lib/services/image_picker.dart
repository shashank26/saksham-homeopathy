import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';

class CImagePicker {
  static Future<MessageImageInfo> getMessageImage(ImageSource source) async {
    MessageImageInfo info = MessageImageInfo();
    final picker = ImagePicker();
    PickedFile rawImage = await picker.getImage(source: source, maxHeight: 500);
    if (rawImage != null) {
      File croppedImage =
          await ImageCropper.cropImage(sourcePath: rawImage.path);
      final File image =
          croppedImage == null ? File(rawImage.path) : croppedImage;
      info.file = image;
      final raw = await FlutterImageCompress.compressWithFile(
        image.absolute.path,
        quality: 10,
      );
      File blurred = File(image.parent.path + '/blurred.png');
      blurred.writeAsBytes(raw);
      info.blurredFile = blurred;
      return info;
    }
    return null;
  }

  static Future<ProfileInfo> getProfilePhoto(ImageSource source, ProfileInfo info) async {
    final picker = ImagePicker();
    PickedFile rawImage = await picker.getImage(source: source, maxHeight: 500);
    if (rawImage != null) {
      File croppedImage =
          await ImageCropper.cropImage(sourcePath: rawImage.path);
      final File image =
          croppedImage == null ? File(rawImage.path) : croppedImage;
      info.file = image;
      return info;
    }
    return null;
  }
}
