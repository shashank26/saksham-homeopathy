import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileInfo {
  String displayName;
  DateTime _dateOfBirth;
  String photoUrl;
  String fileName;
  File file;
  bool isAdmin;

  static final DateFormat formatter = DateFormat('dd-MMM-yyyy');
  ProfileInfo(
      {String displayName,
      dynamic dateOfBirth,
      String photoUrl,
      String fileName,
      File file,
      bool isAdmin}) {
    this.displayName = displayName;
    this.dateOfBirth = dateOfBirth;
    this.photoUrl = photoUrl;
    this.fileName = fileName;
    this.file = file;
    this.isAdmin = isAdmin;
  }

  DateTime get dateOfBirth => _dateOfBirth;

  set dateOfBirth(dynamic dateOfBirth) {
    if (dateOfBirth is DateTime) {
      _dateOfBirth = dateOfBirth;
    } else if (dateOfBirth is Timestamp) {
      _dateOfBirth = DateTime.parse(dateOfBirth.toDate().toString());
    }
  }

  static Map<String, dynamic> toMap(ProfileInfo info) {
    return {
      'displayName': info.displayName,
      'dateOfBirth': info.dateOfBirth,
      'photoUrl': info.photoUrl,
      'fileName': info.fileName
    };
  }

  static ProfileInfo fromMap(Map json) {
    return new ProfileInfo(
        displayName: json['displayName'],
        dateOfBirth: json['dateOfBirth'],
        photoUrl: json['photoUrl'],
        fileName: json['fileName']);
  }
}
