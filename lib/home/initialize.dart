import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:saksham_homeopathy/services/push_notification.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

import 'appPage.dart';

class Initialize extends StatefulWidget {
  @override
  _InitializeState createState() => _InitializeState();
}

class _InitializeState extends State<Initialize> {
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    OTPAuth.initializeInfo().then((value) {
      setState(() {
        initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialized ? AppPage() : ConnectingPage();
  }
}
