import 'package:flutter/material.dart';

import 'constants.dart';

class CustomDialog extends StatelessWidget {
  
  final String _text;

  CustomDialog(this._text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColorPallete.color),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                _text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
