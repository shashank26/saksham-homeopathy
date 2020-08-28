import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/typedefs.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/push_notification.dart';

class OTPAuth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final firestore = Firestore.instance;
  Stream<FirebaseUser> onAuthStateChanged;
  final String _countryCode = '+91';
  AuthCallBack _authCallBack;
  static OTPAuth instance;
  static bool isAdmin = false;
  static FirebaseUser currentUser;
  static String adminId;
  static ProfileInfo adminProfile;

  OTPAuth._() {
    this.onAuthStateChanged = firebaseAuth.onAuthStateChanged;
  }

  static OTPAuth instantiate() {
    if (instance == null) {
      instance = new OTPAuth._();
    }
    return instance;
  }

  static Future<void> initializeInfo() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot ds =
        await FirestoreCollection.userInfo(currentUser.uid).get();
    isAdmin = ds.data['isAdmin'] == true;
    final adminDocument = (await FirestoreCollection.getAdminInfo()).documents[0];
    adminProfile = ProfileInfo.fromMap(adminDocument.data);
    adminId = adminDocument.documentID;
  }

  Future<void> initializeUserProfile(FirebaseUser user) async {
    await firestore.collection('users').document(user.uid).setData(
        ProfileInfo.toMap(
            ProfileInfo(displayName: '', dateOfBirth: null, photoUrl: '', fileName: '', phoneNumber: user.phoneNumber)));
    PushNotification.registerNotification();
  }

  Future authenticate(String phoneNumber, AuthCallBack authCallBack) async {
    this._authCallBack = authCallBack;
    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: this._countryCode + phoneNumber,
        timeout: Duration(minutes: 2),
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String msg) => print(msg));
  }

  Future verifyOTP(
      String verificationId, String smsCode, AuthCallBack authCallBack) async {
    final AuthCredential authCredential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: smsCode);

    try {
      final AuthResult authResult =
          await firebaseAuth.signInWithCredential(authCredential);
      final user = await firebaseAuth.currentUser();
      if (authResult.additionalUserInfo.isNewUser) {
        await initializeUserProfile(user);
      }
      authCallBack(LoginState.verificationCompleted,
          authResult.additionalUserInfo.username);
    } on PlatformException catch (e) {
      if (e.code == 'ERROR_INVALID_VERIFICATION_CODE') {
        authCallBack(LoginState.verificationFailed, 'The otp is invalid.');
      }
      print(e);
    } catch (e) {
      print(e);
    }
  }

  void phoneVerificationFailed(AuthException aex) {
    print(aex.message);
  }

  void phoneVerificationCompleted(AuthCredential cred) {
    print(cred);
  }

  void codeSent(String id, [int forceResendingToken]) {
    if (this._authCallBack != null) {
      this._authCallBack(LoginState.otpSent, id);
    }
  }

  void codeAutoRetrievalTimeout(String msg) {
    print(msg);
  }
}
