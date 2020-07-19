import 'dart:io';

class ProfileInfo {
  String displayName;
  String age;
  String photoUrl;
  String fileName;
  File file;
  bool isAdmin;

  ProfileInfo(
      {String displayName,
      String age,
      String photoUrl,
      String fileName,
      File file,
      bool isAdmin}) {
    this.displayName = displayName;
    this.age = age;
    this.photoUrl = photoUrl;
    this.fileName = fileName;
    this.file = file;
    this.isAdmin = isAdmin;
  }

  static Map<String, dynamic> toMap(ProfileInfo info) {
    return {
      'displayName': info.displayName,
      'age': info.age,
      'photoUrl': info.photoUrl,
      'fileName': info.fileName
    };
  }

  static ProfileInfo fromMap(Map json) {
    return new ProfileInfo(
        displayName: json['displayName'],
        age: json['age'],
        photoUrl: json['photoUrl'],
        fileName: json['fileName']);
  }
}
