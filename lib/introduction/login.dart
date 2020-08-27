import 'package:flutter/material.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal : 40),
        child: LoginForm(),
      )
    );
  }
}
