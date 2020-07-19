import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:uuid/uuid.dart';

class AppColorPallete {
  static const Color color = Color(0xFFF7AFB2);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF5C6773);
}

class ImagePath {
  static final profilePhotoPath = (String uid) => 'photoUrl/$uid.png';
  static final imageMessagePath =
      (String uid) => 'messages/$uid/${Uuid().v1()}.png';
}

class FirestoreCollection {
  static final addMedicine = Firestore.instance.collection('medicines');
  static final chat = (String uid) => Firestore.instance
      .collection('messages')
      .document(uid)
      .collection('chat');
  static final latestMessage = (DocumentReference docRef) =>
      docRef.collection('chat').orderBy('timeStamp', descending: true).limit(1);
  static final unreadMessageCount = (DocumentReference docRef) => docRef
      .collection('chat')
      .where('isRead', isEqualTo: false)
      .where('receiver', isEqualTo: OTPAuth.currentUser.uid)
      .snapshots();
  static final userChatDocument =
      (String uid) => Firestore.instance.collection('messages').document(uid);
  static final messages = Firestore.instance.collection('messages');
  static final userInfo =
      (String uid) => Firestore.instance.collection('users').document(uid);
  static final getAdminInfo =
      () => Firestore.instance.collection('users').where('isAdmin', isEqualTo: true).snapshots().first;
}

class FirebaseStreams {
  static Stream<DocumentSnapshot> profileStream;
  static initializeStreams(FirebaseUser user) {
    profileStream = FirestoreCollection.userInfo(user.uid).snapshots();
  }
}

enum LoginState {
  verficationStart,
  otpSent,
  verificationCompleted,
  verificationFailed,
  timeout,
  codeAutoRetrievalTimeout
}

enum PhotoUploadState { started, inProgress, complete }

enum DialogType { alert, progress }
// final showSnackBar = (context, text) => Scaffold.of(context).showSnackBar(SnackBar(content: text, ))
