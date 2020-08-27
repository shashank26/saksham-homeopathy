import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/typedefs.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class LoginForm extends StatefulWidget {
  final _otpAuth = OTPAuth.instance;

  receiveOTP(String phoneNumber, AuthCallBack authCallBack) async {
    this._otpAuth.authenticate(phoneNumber, authCallBack);
  }

  verifyOTP(
      String verificationId, String otp, AuthCallBack authCallBack) async {
    this._otpAuth.verifyOTP(verificationId, otp, authCallBack);
  }
  
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  LoginState _loginState = LoginState.verficationStart;
  String _phoneNumber, _otp;
  String _verificationId;

  _showDialog(String text, DialogType dialogType) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          if (dialogType == DialogType.progress) {
            return CustomDialog(text);
          } else {
            return AlertDialog(title: Text(text), actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                textColor: AppColorPallete.color,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
          }
        });
  }

  _handleAuthCallBack(LoginState loginState, String verificationId) {
    switch (loginState) {
      case LoginState.otpSent:
        setState(() {
          this._loginState = loginState;
        });
        this._verificationId = verificationId;
        Navigator.pop(context);
        break;
      case LoginState.verificationFailed:
        this._loginState = LoginState.otpSent;
        Navigator.pop(context);
        _showDialog('OTP you entered is invalid!', DialogType.alert);
        break;
      case LoginState.verificationCompleted:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Center(child: HeaderText('Saksham\nHomeopathy')),
          ),
          TextFormField(
            onSaved: (value) {
              if (value.isNotEmpty) _phoneNumber = value;
            },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Phone number',
              prefixIcon: Container(
                width: 60,
                child: Icon(
                  Icons.phone,
                  color: AppColorPallete.color,
                ),
              ),
            ),
            maxLength: 10,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a phone number';
              }
              if (value.length != 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          if (_loginState == LoginState.otpSent)
            TextFormField(
              onSaved: (value) {
                if (value.isNotEmpty) _otp = value;
              },
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'OTP',
                prefixIcon: Icon(
                  Icons.fiber_pin,
                  color: AppColorPallete.color,
                ),
              ),
              maxLength: 6,
              validator: (value) {
                if (value.isEmpty || value.length != 6) {
                  return 'Please enter a valid OTP';
                }
                return null;
              },
            ),
          Container(
            margin: EdgeInsetsDirectional.only(top: 20),
            child: MaterialButton(
              color: AppColorPallete.color,
              minWidth: double.infinity,
              elevation: 0,
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: () async {
                _formKey.currentState.save();
                if (_formKey.currentState.validate()) {
                  if (_loginState == LoginState.verficationStart) {
                    _showDialog('Sending OTP...', DialogType.progress);
                    widget.receiveOTP(this._phoneNumber, this._handleAuthCallBack);
                  } else if (_loginState == LoginState.otpSent) {
                    _showDialog('Verifying OTP...', DialogType.progress);
                    widget.verifyOTP(
                        this._verificationId, this._otp, this._handleAuthCallBack);
                  }
                }
              },
              child: Text(
                _loginState == LoginState.verficationStart
                    ? 'Receive OTP'
                    : 'Login',
              ),
            ),
          )
        ],
      ),
    );
  }
}
