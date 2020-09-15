import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AppColorPallete {
  static const Color color = Color(0xFFF7AFB2);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF5C6773);
}

class LocalStorage {
  static final profileStorage =
      (String uid) => 'profileInfo/$uid/profileInfo.json';
  static final chatStorage = (String uid) => 'messages/$uid/chat.json';
}

class ImagePath {
  static final profilePhotoPath =
      (String uid) => 'photoUrl/$uid/${Uuid().v1()}.png';
  static final imageMessagePath =
      (String uid) => 'messages/$uid/${Uuid().v1()}.png';
  static final imagePostPath = () => 'adminPosts/${Uuid().v1()}.png';
}

class FirestoreCollection {
  static final addMedicine = (String uid) => Firestore.instance
      .collection('medicines')
      .document(uid)
      .collection('medicines');
  static final chat = (String uid) => Firestore.instance
      .collection('messages')
      .document(uid)
      .collection('chat');
  static final latestMessage = (String uid) =>
      chat(uid).orderBy('timeStamp', descending: true).limit(1).snapshots();
  static final userChatDocument =
      (String uid) => Firestore.instance.collection('messages').document(uid);
  static final messages = Firestore.instance.collection('messages');
  static final userInfo =
      (String uid) => Firestore.instance.collection('users').document(uid);
  static final getAdminInfo = () => Firestore.instance
      .collection('users')
      .where('isAdmin', isEqualTo: true)
      .snapshots()
      .first;
  static final adminUpdates = (int size) => Firestore.instance
      .collection('adminUpdates')
      .limit(size)
      .orderBy('timeStamp', descending: true);
  static final postUpdate = Firestore.instance.collection('adminUpdates');
  static final profileStream =
      (uid) => FirestoreCollection.userInfo(uid).snapshots();
  static final isWhiteListed = (phoneNumber) => Firestore.instance
      .collection('whitelist')
      .where('phoneNumber', isEqualTo: phoneNumber)
      .snapshots();
  static final updateRequired =
      () => Firestore.instance.collection('update').snapshots();
}

enum LoginState {
  verficationStart,
  otpSent,
  verificationCompleted,
  verificationFailed,
  timeout,
  codeAutoRetrievalTimeout
}

enum UpdateType { Recommended, Required }

enum PhotoUploadState { started, inProgress, complete }

enum DialogType { alert, progress }

Function noe = (String str) => str == null || str.trim() == '';

class AESEncryption {
  static final _aesEncrypter = enc.Encrypter(
      enc.AES(enc.Key.fromUtf8('1817a28b955c43f7960d8446aed33763')));
  static final _aesEncryptionIV = enc.IV.fromLength(16);

  static encrypt(String text) {
    try {
      return _aesEncrypter.encrypt(text, iv: _aesEncryptionIV).base64;
    } on Exception catch (e) {
      return text;
    }
  }

  static decrypt(String text) {
    try {
      return _aesEncrypter.decrypt64(text, iv: _aesEncryptionIV);
    } on Exception catch (e) {
      return text;
    }
  }
}
