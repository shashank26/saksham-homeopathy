import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_video_compress/flutter_video_compress.dart' as vc;
import 'package:googleapis/youtube/v3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/models/admin_post.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'google_auth.dart';

class FileHandler {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: FirebaseConstants.STORAGE_BUCKET);
  String applicationDirectoryPath;
  DefaultCacheManager _cacheManager;
  static FileHandler instance;
  // final _flutterVideoCompress = vc.FlutterVideoCompress();

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

  Future<AdminPost> uploadPostImage(AdminPost file) async {
    file.fileName = ImagePath.imagePostPath();
    file.fileUrl = await _uploadFile(file.file, file.fileName);
    await writeFile(file.file, file.fileName);
    return file;
  }

  Future<String> uploadFile(File file, String fileName) async {
    final fileUrl = await _uploadFile(file, fileName);
    await writeFile(file, fileName);
    return fileUrl;
  }

  Stream<StorageTaskEvent> uploadFileWithStatus(File file, String fileName) {
    StorageUploadTask task = _storage.ref().child(fileName).putFile(file);
    return task.events;
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

  // vc.Subscription _compressionSubscription;
  // Future<File> compressMP4File(File file, {Function status}) async {
  //   try {
  //     if (_compressionSubscription == null)
  //       _compressionSubscription =
  //           _flutterVideoCompress.compressProgress$.subscribe((progress) {
  //         if (status != null) status(progress);
  //       });
  //     vc.MediaInfo mediaInfo = await _flutterVideoCompress.compressVideo(
  //       file.path,
  //       quality: vc.VideoQuality.MediumQuality,
  //       deleteOrigin: false,
  //     );
  //     return mediaInfo.file;
  //   } on Exception catch (e) {
  //     return file;
  //   }
  // }

  Future<AdminPost> uploadToYoutube(AdminPost post) async {
    final client = await GoogleAuth.instance.getClient();
    var yt = YoutubeApi(client);
    Video video = new Video();

    VideoSnippet snippet = new VideoSnippet();
    snippet.categoryId = "22";
    snippet.description = "Saksham Homeopathy";
    snippet.title = post.fileName;
    video.snippet = snippet;

    VideoStatus status = new VideoStatus();
    status.privacyStatus = "public";
    video.status = status;

    Media m = Media(post.file.openRead(), post.file.lengthSync());
    post.file.openRead().listen((event) {
      print(event);
    });
    Video vid = await yt.videos.insert(video, 'snippet,status', uploadMedia: m);
    post.fileUrl = vid.id;
    post.videoThumbnail = vid.id;
    return post;
  }

  Future<AdminPost> uploadPostFile(AdminPost post) {
    if (post.file.path.endsWith('.mp4')) {
      return uploadToYoutube(post);
    } else {
      return uploadPostImage(post);
    }
  }
}
