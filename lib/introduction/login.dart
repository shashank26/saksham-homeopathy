import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  final OTPAuth _otpAuth;
  LoginPage(this._otpAuth);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal : 40),
        child: LoginForm(this._otpAuth),
      )
    );
  }
}
