import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';

class Index extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("images/saksham_homeopathy.jpeg"),
                height: 200,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: HeaderText('Saksham\nHomeopathy'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: AppColorPallete.color,
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
