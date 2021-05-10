import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'otp_auth.dart';

class PushNotification {
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static void registerNotification() {
    firebaseMessaging.requestPermission().then((NotificationSettings ns) {
      firebaseMessaging.getToken().then((token) async {
        print('token: $token');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(OTPAuth.currentUser.uid)
            .update({'pushToken': token});
      }).catchError((err) {
        // Fluttertoast.showToast(msg: err.message.toString());
      });
    });

    // firebaseMessaging.configure(
    //     onMessage: (Map<String, dynamic> message) {
    //   if (OTPAuth.currentUser != null) {
    //     print('onMessage: $message');
    //     Platform.isAndroid
    //         ? print(message['notification'])
    //         : print(message['aps']['alert']);
    //   }

    //   return;
    // }, onResume: (Map<String, dynamic> message) {
    //   print('onResume: $message');
    //   return;
    // }, onLaunch: (Map<String, dynamic> message) {
    //   print('onLaunch: $message');
    //   return;
    // });
  }
}
