import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'otp_auth.dart';

class PushNotification {
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  static void registerNotification() {
    
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      
      print('onMessage: $message');
      Platform.isAndroid
          ? print(message['notification'])
          : print(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) async {
      print('token: $token');
      await Firestore.instance
          .collection('users')
          .document(OTPAuth.currentUser.uid)
          .updateData({'pushToken': token});
    }).catchError((err) {
      // Fluttertoast.showToast(msg: err.message.toString());
    });
  }
}
