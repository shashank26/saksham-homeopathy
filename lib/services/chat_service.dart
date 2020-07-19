import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';
import 'file_handler.dart';
import 'image_picker.dart';

class ChatService {
  String _sender;
  String _receiver;
  CollectionReference chatRef;
  FirebaseUser _user = OTPAuth.currentUser;
  FileHandler _fileHandler = FileHandler.instance;
  static StreamController<int> unreadChats = StreamController.broadcast();

  ChatService({String receiver}) {
    this._receiver = receiver;
    chatRef = FirestoreCollection.chat(OTPAuth.isAdmin ? receiver : _user.uid);
    _sender = _user.uid;
  }

  Stream<QuerySnapshot> getChatStream() {
    return chatRef.orderBy('timeStamp', descending: true).snapshots();
  }

  static Stream<QuerySnapshot> unreadMessageStream(
      DocumentReference documentReference) {
    return FirestoreCollection.unreadMessageCount(documentReference);
  }

  updateTimestamp(bool isNewChat) async {
    String uid = _user.uid;
    if (OTPAuth.isAdmin) {
      uid = _receiver;
    }
    if (isNewChat)
      await FirestoreCollection.userChatDocument(uid)
          .setData({'latestTimestamp': DateTime.now()});
    else
      await FirestoreCollection.userChatDocument(uid)
          .setData({'latestTimestamp': DateTime.now()});
  }

  Future sendMessage(String message, bool isNewChat) async {
    MessageInfo info = MessageInfo(
        _sender, _receiver, message, null, null, null, DateTime.now(), false);
    await chatRef.add(MessageInfo.toMap(info));
    await updateTimestamp(isNewChat);
  }

  sendNotification(String message) async {
    final data = MessageInfo.toMap(MessageInfo(_sender, _receiver, message,
        null, null, null, DateTime.now().toString(), false));
    final res = await CloudFunctions.instance
        .getHttpsCallable(functionName: 'sendNotification')
        .call(data);
    print(res);
  }

  sendImage(bool isNewChat) async {
    final images = await CImagePicker.getMessageImage(ImageSource.camera);
    if (images != null) {
      images.blurredFileName = ImagePath.imageMessagePath(_user.uid);
      images.fileName = ImagePath.imageMessagePath(_user.uid);
      MessageImageInfo uploadedImages =
          await _fileHandler.uploadMessageImage(images);

      await chatRef.add(MessageInfo.toMap(MessageInfo(
          _sender,
          _receiver,
          null,
          uploadedImages.blurredUrl,
          uploadedImages.url,
          uploadedImages.fileName,
          DateTime.now(),
          false)));
      await updateTimestamp(isNewChat);
    }
  }

  static Future<ProfileInfo> setProfilePhoto(
      ProfileInfo info, DocumentReference userDocRef, Function uploadStarted) async {
    final images = await CImagePicker.getProfilePhoto(ImageSource.camera, info);
    if (images != null) {
      images.fileName = ImagePath.profilePhotoPath(userDocRef.documentID);
      uploadStarted();
      ProfileInfo uploadedImages =
          await FileHandler.instance.uploadProfilePhoto(images);
      imageCache.clear();
      await userDocRef.updateData(ProfileInfo.toMap(uploadedImages));
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

  static Stream<QuerySnapshot> getLatestMessageStream(
      DocumentReference docRef) {
    return FirestoreCollection.latestMessage(docRef).snapshots();
  }

  static initializeUnreadMessageStream({DocumentReference documentReference}) {
    if (ChatService.unreadChats.isClosed)
      ChatService.unreadChats = StreamController.broadcast();
    if (OTPAuth.isAdmin) {
      final unreadMap = new HashMap<String, int>();
      ChatService.getChatListStream().listen((event) {
        event.documents.forEach((element) {
          unreadMap.putIfAbsent(element.documentID, () => 0);
          ChatService.unreadMessageStream(element.reference).listen((event) {
            unreadMap.update(
                element.documentID, (value) => event.documents.length);
            ChatService.unreadChats.add(
                unreadMap.values.reduce((value, element) => value + element));
          });
        });
      });
    } else {
      unreadMessageStream(documentReference).listen((event) {
        ChatService.unreadChats.add(event.documents.length);
      });
    }
  }
}
