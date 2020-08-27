import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPost {
  String imageName;
  String imageUrl;
  File image;
  String href;
  String text;
  DateTime _timeStamp;

  AdminPost(
      {String text,
      File image,
      String imageName,
      String imageUrl,
      String href,
      dynamic timeStamp}) {
    this.text = text;
    this.image = image;
    this.imageName = imageName;
    this.imageUrl = imageUrl;
    this.href = href;
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
      'imageName': info.imageName,
      'imageUrl': info.imageUrl,
      'href ': info.href,
      'timeStamp': info.timeStamp,
    };
  }

  static AdminPost fromMap(Map json) {
    return new AdminPost(
      text : json['text'],
      imageName : json['imageName'],
      imageUrl : json['imageUrl'],
      href : json['href'],
      timeStamp : json['timeStamp'],
    );
  }

  static final DateFormat defaultForamt = DateFormat.yMd().add_jm();
  static final DateFormat weekdayFormat = DateFormat('EEEE').add_jm();
}
