import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';

class FileHandler {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://flutter-learn-3fcb5.appspot.com');
  String _applicationDirectoryPath;
  DefaultCacheManager _cacheManager;
  static FileHandler instance;

  static instantiate() async {
    if (instance == null) {
      instance = new FileHandler();
    }
    instance._applicationDirectoryPath =
        (await getApplicationDocumentsDirectory()).path;
    instance._cacheManager = DefaultCacheManager();
    return instance;
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
    await writeFile(file.file, file.fileName);
    return file;
  }

  Future<AdminPost> uploadPostImage(AdminPost file,
      {Function callBack}) async {
    file.imageUrl = await _uploadFile(file.image, file.imageName);
    await writeFile(file.image, file.imageName);
    return file;
  }

  Future<String> _uploadFile(File file, String fileName) async {
    StorageUploadTask task = _storage.ref().child(fileName).putFile(file);
    StorageTaskSnapshot snapshot = await task.onComplete;
    if(!task.isSuccessful) throw new Exception('Failed to send the image! Please try again.');
    return await snapshot.ref.getDownloadURL();
  }

  Future<File> writeFile(File file, String fileName) async {
    final path = '$_applicationDirectoryPath/$fileName';
    File image = File(path);
    image.createSync(recursive: true);
    return await image.writeAsBytes(file.readAsBytesSync());
  }

  Future<File> getFile(String url, String fileName) async {
    final path = '$_applicationDirectoryPath/$fileName';
    File img = File(path);
    if (!img.existsSync()) {
      FileInfo info = await _cacheManager.downloadFile(url);
      img = await writeFile(info.file, fileName);
    }
    return img;
  }

  File getRawFile(String fileName) {
    File img = File(fileName);
    if (!img.existsSync()) {
      return null;
    }
    return img;
  }

   void deleteRaw(File file) {
    file.deleteSync();
  }

  // File deleteCloud(String fileName) {
  //   File img = File(fileName);
  //   if (!img.existsSync()) {
  //     return null;
  //   }
  //   return img;
  // }

  bool exists(String fileName) {
    final path = '$_applicationDirectoryPath/$fileName';
    File img = File(path);
    return img.existsSync();
  }
}
