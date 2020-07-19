import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/home/initialize.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:saksham_homeopathy/introduction/index.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: OTPAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ConnectingPage();
          }
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return Index();
          }
          return Initialize();
        });
  }
}
