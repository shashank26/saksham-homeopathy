import 'dart:io';

class MessageImageInfo {

  MessageImageInfo({this.url, this.fileName, this.file, this.blurredUrl, this.blurredFileName, this.blurredFile});

  String url;
  String blurredUrl;
  String fileName;
  String blurredFileName;
  File file;
  File blurredFile;
}
