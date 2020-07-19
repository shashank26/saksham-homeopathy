import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:saksham_homeopathy/common/constants.dart';

class ConnectingPage extends StatefulWidget {
  @override
  _ConnectingPageState createState() => _ConnectingPageState();
}

class _ConnectingPageState extends State<ConnectingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LoadingBouncingGrid.square(backgroundColor: AppColorPallete.color),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Loading. Please wait...',
                style: TextStyle(
                  color: AppColorPallete.textColor,
                  fontFamily: 'Raleway',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
