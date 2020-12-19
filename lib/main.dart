// import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/landing_page.dart';
// import 'package:saksham_homeopathy/no_connectivity.dart';
import 'introduction/login.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        primaryColor: AppColorPallete.color,
        accentColor: AppColorPallete.textColor,
        scaffoldBackgroundColor: Colors.white),
    title: 'Saksham Homeopathy',
    home: LandingPage(),
        // child: StreamBuilder<ConnectivityResult>(
        //     stream: Connectivity().onConnectivityChanged,
        //     builder: (context, snapshot) {
        //       return IndexedStack(
        //         index: snapshot.data == ConnectivityResult.mobile ||
        //                 snapshot.data == ConnectivityResult.wifi
        //             ? 0
        //             : 1,
        //         children: <Widget>[
        //           LandingPage(),
        //           NoConnectivity(),
        //         ],
        //       );
        //     })

    routes: <String, WidgetBuilder>{
      '/login': (BuildContext context) => LoginPage(),
    },
  ));
}
