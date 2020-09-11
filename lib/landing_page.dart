import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:saksham_homeopathy/home/initialize.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:saksham_homeopathy/introduction/index.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common/constants.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _initializationFlag = false;
  bool _recommendedUpdateFlag = false;
  bool _requiredUpdateFlag = false;

  @override
  void initState() {
    super.initState();

    FirestoreCollection.updateRequired().listen((event) async {
      _initializationFlag =
          _recommendedUpdateFlag = _requiredUpdateFlag = false;
      if (event.documents.length == 0) {
        return;
      }
      final packageInfo = await PackageInfo.fromPlatform();

      final updateType =
          UpdateType.values[event.documents.first.data['updateType']];
      final version = event.documents.first.data['version'];
      final buildNumber = event.documents.first.data['buildNumber'];

      bool isUpdated = packageInfo.version == version &&
          packageInfo.buildNumber == buildNumber;

      if (isUpdated) {
        _init();
      } else if (updateType == UpdateType.Recommended) {
        setState(() {
          _recommendedUpdateFlag = true;
        });
      } else if (updateType == UpdateType.Required) {
        setState(() {
          _requiredUpdateFlag = true;
        });
      }
    });
  }

  _init() {
    OTPAuth.instantiate();
    FileHandler.instantiate().then((val) {
      setState(() {
        _initializationFlag = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationFlag) {
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
    if (_requiredUpdateFlag || _recommendedUpdateFlag) {
      return Material(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: AppColorPallete.backgroundColor,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please update the app.',
                style:
                    TextStyle(color: AppColorPallete.textColor, fontSize: 16),
              ),
              MaterialButton(
                color: AppColorPallete.color,
                elevation: 5,
                onPressed: () {
                  launch('http://play.google.com/store/apps/details?id=com.ibis.saksham_homeopathy');
                },
                child: Text(
                  'Update',
                  style: TextStyle(color: AppColorPallete.backgroundColor),
                ),
              ),
              Visibility(
                visible: _recommendedUpdateFlag,
                child: MaterialButton(
                  color: AppColorPallete.textColor,
                  elevation: 5,
                  onPressed: () {
                    _init();
                  },
                  child: Text(
                    'Later',
                    style: TextStyle(color: AppColorPallete.backgroundColor),
                  ),
                ),
              )
            ],
          )),
        ),
      );
    }
    return ConnectingPage();
  }
}
