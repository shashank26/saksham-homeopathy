import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/landing_page.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'introduction/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final OTPAuth _otpAuth = OTPAuth.instantiate();
  await FileHandler.instantiate();
  runApp(MaterialApp(
    theme: ThemeData(
        primaryColor: AppColorPallete.color,
        accentColor: AppColorPallete.textColor,
        scaffoldBackgroundColor: Colors.white),
    title: 'Saksham Homeopathy',
    home: SafeArea(
        child: StreamBuilder<ConnectivityResult>(
            stream: Connectivity().onConnectivityChanged,
            builder: (context, snapshot) {
              return IndexedStack(
                index: snapshot.data == ConnectivityResult.mobile ||
                        snapshot.data == ConnectivityResult.wifi
                    ? 0
                    : 1,
                children: <Widget>[
                  LandingPage(),
                  Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Material(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Wrap(
                            children: <Widget>[
                              Icon(
                                Icons
                                    .signal_cellular_connected_no_internet_4_bar,
                                color: AppColorPallete.textColor,
                                size: 50,
                              ),
                            ],
                          ),
                          HeaderText(
                            'Please connect to internet.',
                            size: 16,
                          ),
                        ],
                      ))),
                ],
              );
            })),
    routes: <String, WidgetBuilder>{
      '/login': (BuildContext context) => LoginPage(_otpAuth),
    },
  ));
}
