import 'package:cloud_firestore/cloud_firestore.dart';

class MessageInfo {
  String blurredImage;
  String image;
  String sender;
  String message;
  DateTime _timeStamp;
  String receiver;
  String fileName;
  bool _isRead;

  MessageInfo(String sender, String receiver, String message,
      String blurredImage, String image, String fileName, dynamic timeStamp, dynamic isRead) {
    this.sender = sender;
    this.receiver = receiver;
    this.message = message;
    this.blurredImage = blurredImage;
    this.image = image;
    this.fileName = fileName;
    this.timeStamp = timeStamp;
    this.isRead = isRead;
  }

  DateTime get timeStamp => _timeStamp;

  set timeStamp(dynamic timeStamp) {
    if (timeStamp is DateTime) {
      _timeStamp = timeStamp;
    } else if (timeStamp is Timestamp) {
      _timeStamp = DateTime.parse(timeStamp.toDate().toString());
    }
  }

  bool get isRead => _isRead;

  set isRead(dynamic isRead) {
    if (isRead is bool) {
      _isRead = isRead;
    } else {
      _isRead = isRead == 'true';
    }
  }

  static Map<String, dynamic> toMap(MessageInfo info) {
    return {
      'sender': info.sender,
      'receiver': info.receiver,
      'message': info.message,
      'blurredImage': info.blurredImage,
      'image': info.image,
      'fileName': info.fileName,
      'timeStamp': info.timeStamp,
      'isRead' : info.isRead,
    };
  }

  static MessageInfo fromMap(Map json) {
    return new MessageInfo(
        json['sender'],
        json['receiver'],
        json['message'],
        json['blurredImage'],
        json['image'],
        json['fileName'],
        json['timeStamp'],
        json['isRead']);
  }
}
