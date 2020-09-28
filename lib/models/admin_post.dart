import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPost {
  String fileName;
  String fileUrl;
  File file;
  String videoThumbnail;
  String text = "";  
  DateTime _timeStamp;

  AdminPost(
      {String text,
      File file,
      String fileName,
      String videoThumbnail,
      String fileUrl,
      dynamic timeStamp}) {
    this.text = text;
    this.file = file;
    this.fileName = fileName;
    this.fileUrl = fileUrl;
    this.videoThumbnail = videoThumbnail;
    this.timeStamp = timeStamp;
  }

  DateTime get timeStamp => _timeStamp;

  set timeStamp(dynamic timeStamp) {
    if (timeStamp is DateTime) {
      _timeStamp = timeStamp;
    } else if (timeStamp is Timestamp) {
      _timeStamp = DateTime.parse(timeStamp.toDate().toString());
    }
  }

  String getTimestamp() {
    if (DateTime.now().difference(this._timeStamp) < Duration(days: 7)) {
      return weekdayFormat.format(this._timeStamp);
    }
    return defaultForamt.format(this._timeStamp);
  }

  static Map<String, dynamic> toMap(AdminPost info) {
    return {
      'text': info.text,
      'fileName': info.fileName,
      'fileUrl': info.fileUrl,
      'timeStamp': info.timeStamp,
      'videoThumbnail': info.videoThumbnail,
    };
  }

  static AdminPost fromMap(Map json) {
    return new AdminPost(
      text : json['text'],
      fileName : json['fileName'],
      fileUrl : json['fileUrl'],
      timeStamp : json['timeStamp'],
      videoThumbnail : json['videoThumbnail'],
    );
  }

  static final DateFormat defaultForamt = DateFormat.yMd().add_jm();
  static final DateFormat weekdayFormat = DateFormat('EEEE').add_jm();
}
