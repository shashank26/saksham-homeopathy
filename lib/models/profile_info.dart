import 'dart:io';
import 'package:intl/intl.dart';

class ProfileInfo {
  String displayName;
  dynamic dateOfBirth;
  String photoUrl;
  String fileName;
  File file;
  bool isAdmin;
  String phoneNumber;

  static final DateFormat formatter = DateFormat('dd-MMM-yyyy');
  ProfileInfo(
      {String displayName,
      dynamic dateOfBirth,
      String photoUrl,
      String fileName,
      File file,
      bool isAdmin,
      String phoneNumber}) {
    this.displayName = displayName;
    this.dateOfBirth = dateOfBirth;
    this.photoUrl = photoUrl;
    this.fileName = fileName;
    this.file = file;
    this.isAdmin = isAdmin;
    this.phoneNumber = phoneNumber;
  }

  static Map<String, dynamic> toMap(ProfileInfo info) {
    return {
      'displayName': info.displayName,
      'dateOfBirth': info.dateOfBirth,
      'photoUrl': info.photoUrl,
      'fileName': info.fileName,
      'phoneNumber' : info.phoneNumber,
    };
  }

  static ProfileInfo fromMap(Map json) {
    return new ProfileInfo(
        displayName: json['displayName'],
        dateOfBirth: json['dateOfBirth'],
        photoUrl: json['photoUrl'],
        fileName: json['fileName'],
        phoneNumber : json['phoneNumber']);
  }
}
