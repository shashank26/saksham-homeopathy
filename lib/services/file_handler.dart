import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';

class FileHandler {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://saksham-homeopathy.appspot.com');
  String applicationDirectoryPath;
  DefaultCacheManager _cacheManager;
  static FileHandler instance;

  static Future instantiate() async {
    if (instance == null) {
      instance = new FileHandler();
    }
    instance.applicationDirectoryPath =
        (await getApplicationDocumentsDirectory()).path;
    instance._cacheManager = DefaultCacheManager();
  }

  Future<MessageImageInfo> uploadMessageImage(MessageImageInfo file,
      {Function callBack}) async {
    file.url = await _uploadFile(file.file, file.fileName);
    file.blurredUrl = await _uploadFile(file.blurredFile, file.blurredFileName);
    await writeFile(file.file, file.fileName);
    return file;
  }

  Future<ProfileInfo> uploadProfilePhoto(ProfileInfo file,
      {Function callBack}) async {
    file.photoUrl = await _uploadFile(file.file, file.fileName);
    return file;
  }

  Future<AdminPost> uploadPostImage(AdminPost file, {Function callBack}) async {
    file.imageUrl = await _uploadFile(file.image, file.imageName);
    await writeFile(file.image, file.imageName);
    return file;
  }

  Future<String> _uploadFile(File file, String fileName) async {
    StorageUploadTask task = _storage.ref().child(fileName).putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    if (!task.isSuccessful)
      throw new Exception('Failed to send the image! Please try again.');
    return await snapshot.ref.getDownloadURL();
  }

  Future deleteCloudFile(String fileName) async {
    await _storage.ref().child(fileName).delete();
  }

  Future<File> writeFile(File file, String fileName) async {
    final path = '$applicationDirectoryPath/$fileName';
    File image = File(path);
    image.createSync(recursive: true);
    return await image.writeAsBytes(file.readAsBytesSync());
  }

  Future<File> getFile(String url, String fileName) async {
    final path = '$applicationDirectoryPath/$fileName';
    File img = File(path);
    if (!img.existsSync()) {
      FileInfo info = await _cacheManager.downloadFile(url);
      img = await writeFile(info.file, fileName);
    }
    return img;
  }

  void writeRawFile(String fileName, {List<int> bytes, String json}) {
    File file = File(fileName);
    if (!this.exists(full: fileName)) {
      file.createSync(recursive: true);
    }
    if (bytes != null) {
      file.writeAsBytesSync(bytes);
      return;
    }
    if (json != null) {
      file.writeAsStringSync(json, flush: true);
      return;
    }
  }

  File getRawFile({String fileName, String fullName}) {
    if (!this.exists(fileName: fileName) && !this.exists(full: fullName)) {
      return null;
    }

    if (!noe(fileName)) {
      return File('$applicationDirectoryPath/$fileName');
    } else {
      return File(fullName);
    }
  }

  String getFileName({String path, File file}) {
    if (file != null) {
      path = file.path;
    }
    return path.split(Platform.pathSeparator).last;
  }

  void deleteRaw(File file) {
    file.deleteSync();
  }

  bool exists({String fileName, String full}) {
    File img;
    if (!noe(fileName)) {
      img = File('$applicationDirectoryPath/$fileName');
    } else if (!noe(full)) {
      img = File(full);
    } else {
      return false;
    }
    return img.existsSync();
  }
}
