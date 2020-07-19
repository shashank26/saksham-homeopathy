import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<String> _uploadFile(File file, String fileName) async {
    StorageTaskSnapshot snapshot =
        await _storage.ref().child(fileName).putFile(file).onComplete;
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

  bool exists(String fileName) {
    final path = '$_applicationDirectoryPath/$fileName';
    File img = File(path);
    return img.existsSync();
  }
}
