import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';
import 'file_handler.dart';
import 'image_picker.dart';
import 'package:http/http.dart' as http;

class ChatService {
  String _sender;
  String receiver;
  CollectionReference _chatRef;
  FirebaseUser _user = OTPAuth.currentUser;
  FileHandler _fileHandler = FileHandler.instance;
  String chatId;
  static StreamController<Map<String, bool>> unreadStreamController;

  ChatService(String receiver) {
    this.chatId = OTPAuth.isAdmin ? receiver : _user.uid;
    this.receiver = receiver;
    _chatRef = FirestoreCollection.chat(chatId);
    _sender = _user.uid;
  }

  Stream<QuerySnapshot> getChatStream(int limit) {
    return _chatRef
        .orderBy('timeStamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<QuerySnapshot> getOldMessages(DocumentSnapshot after) {
    return _chatRef
        .orderBy('timeStamp', descending: true)
        .startAfterDocument(after)
        .limit(10)
        .getDocuments();
  }

  updateTimestamp(bool isNewChat) async {
    await FirestoreCollection.userChatDocument(chatId)
        .setData({'latestTimestamp': DateTime.now()});
  }

  Future sendMessage(String message, bool isNewChat) async {
    MessageInfo info = MessageInfo(
        _sender, receiver, message, null, null, null, DateTime.now(), false);
    await _chatRef.add(MessageInfo.toMap(info));
    await updateTimestamp(isNewChat);
  }

  sendNotification(String message, String token,
      {bool isEmergency = false}) async {
    try {
      final serverToken =
          'AAAAVjsrpIY:APA91bG_k_WlY3uAmmKln8wX3SyrU-f-Rz4sh_YLkNaoon6ckv8xLJ63f_zrMRmQsInKEPlMOt9Z8fKOObgdhsVv_hheAzivRIUeNQBNCEWWK1sTrr7TKNTKhFmvoyfU2k-pa777OcFN';
      final response = await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': message,
              'title':
                  '${OTPAuth.currentUserProfile.displayName} (${OTPAuth.currentUser.phoneNumber})',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
          },
        ),
      );
      print(response);
    } on Exception catch (ex) {
      print(ex);
    }
  }

  sendImage(bool isNewChat, ImageSource imageSource) async {
    final images = await CImagePicker.getMessageImage(imageSource);
    if (images != null) {
      images.blurredFileName = ImagePath.imageMessagePath(_user.uid);
      images.fileName = ImagePath.imageMessagePath(_user.uid);
      MessageImageInfo uploadedImages =
          await _fileHandler.uploadMessageImage(images);

      await _chatRef.add(MessageInfo.toMap(MessageInfo(
          _sender,
          receiver,
          null,
          uploadedImages.blurredUrl,
          uploadedImages.url,
          uploadedImages.fileName,
          DateTime.now(),
          false)));
    }
    await updateTimestamp(isNewChat);
  }

  static Future<ProfileInfo> setProfilePhoto(
      ProfileInfo info,
      DocumentReference userDocRef,
      Function uploadStarted,
      ImageSource source) async {
    final images = await CImagePicker.getProfilePhoto(source, info);
    if (images != null) {
      final oldImage = info.fileName;
      final oldFile = info.file;
      images.fileName = ImagePath.profilePhotoPath(userDocRef.documentID);
      uploadStarted();
      ProfileInfo uploadedImages =
          await FileHandler.instance.uploadProfilePhoto(images);
      imageCache.clear();
      await userDocRef.updateData(ProfileInfo.toMap(uploadedImages));
      if (!noe(oldImage) && oldFile != null) {
        await FileHandler.instance.deleteCloudFile(oldImage);
        FileHandler.instance.deleteRaw(oldFile);
      }
      return uploadedImages;
    }
    return null;
  }

  MessageInfo getMessageInfo(AsyncSnapshot<dynamic> snapshot, index) {
    return MessageInfo.fromMap(snapshot.data.documents[index].data);
  }

  static Stream<QuerySnapshot> getChatListStream() {
    return FirestoreCollection.messages
        .orderBy('latestTimestamp', descending: true)
        .snapshots();
  }

  static Stream<DocumentSnapshot> getUserInfo(String uid) {
    return FirestoreCollection.userInfo(uid).snapshots();
  }

  static Future postUpdate(String text) async {
    await FirestoreCollection.postUpdate.add(
        {'postImage': null, 'postText': text, 'timeStamp': DateTime.now()});
  }

  // only for user not admin
  static StreamSubscription<QuerySnapshot> unreadMessageStream() {
    return FirestoreCollection.latestMessage(OTPAuth.currentUser.uid)
        .listen((event) {
      if (event.documents.length == 1) {
        MessageInfo info = MessageInfo.fromMap(event.documents[0].data);
        ChatService.unreadStreamController.add(Map.fromEntries([
          MapEntry(OTPAuth.currentUser.uid,
              info.sender != OTPAuth.currentUser.uid && !info.isRead)
        ]));
      }
    });
  }
}
