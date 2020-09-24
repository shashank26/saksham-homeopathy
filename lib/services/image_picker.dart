import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';

class CImagePicker {
  static ImagePicker _picker = ImagePicker();

  static Future<PickedFile> _getRawImage(ImageSource source) async {
    try {
      return await _picker.getImage(source: source, maxHeight: 500);
    } on Exception catch (e) {
      return null;
    }
  }

  static Future<PickedFile> _getRawVideo(ImageSource source) async {
    try {
      return await _picker.getVideo(source: source);
    } on Exception catch (e) {
      return null;
    }
  }

  static Future<File> _getCroppedImage(String sourcePath) async {
    try {
      return await ImageCropper.cropImage(sourcePath: sourcePath);
    } on Exception catch (e) {
      return null;
    }
  }

  static Future<MessageImageInfo> getMessageImage(ImageSource source) async {
    MessageImageInfo info = MessageImageInfo();

    PickedFile rawImage = await _getRawImage(source);
    if (rawImage == null) {
      return null;
    }

    File croppedImage = await _getCroppedImage(rawImage.path);
    if (croppedImage == null) {
      return null;
    }
    final File image =
        croppedImage == null ? File(rawImage.path) : croppedImage;
    info.file = image;
    final raw = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      quality: 5,
    );
    File blurred = File(image.parent.path + '/blurred.png');
    blurred.writeAsBytes(raw);
    info.blurredFile = blurred;
    return info;
  }

  static Future<ProfileInfo> getProfilePhoto(
      ImageSource source, ProfileInfo info) async {
    PickedFile rawImage = await _getRawImage(source);

    if (rawImage == null) return null;

    File croppedImage = await _getCroppedImage(rawImage.path);

    if (croppedImage == null) return null;

    final File image =
        croppedImage == null ? File(rawImage.path) : croppedImage;
    info.file = image;
    return info;
  }

  static Future<File> getImage(ImageSource source) async {
    PickedFile rawImage = await _getRawImage(source);
    if (rawImage == null) return null;

    File croppedImage = await _getCroppedImage(rawImage.path);

    if (croppedImage == null) return null;

    final File image =
        croppedImage == null ? File(rawImage.path) : croppedImage;
    return image;
  }

  static Future<File> getVideo(ImageSource source) async {
    PickedFile rawVideo = await _getRawVideo(source);
    if (rawVideo != null) return File(rawVideo.path);
    return null;
  }
}
