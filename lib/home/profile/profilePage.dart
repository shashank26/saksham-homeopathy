import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/date_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/image_source_bottom_sheet.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = OTPAuth.currentUser;

  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController(text: '');
  final _dobController = TextEditingController(text: '');
  final _phoneNumberController = TextEditingController(text: '');
  ProfileInfo _profileInfo;
  final DocumentReference _userDocRef =
      FirestoreCollection.userInfo(OTPAuth.currentUser.uid);
  final _snackBarDefaultDuration = Duration(seconds: 4);

  Future<bool> _getProfileInfo() async {
    Map<String, dynamic> data =
        FileHandler.instance.getProfileInfo(OTPAuth.currentUser.uid);
    if (data == null) {
      DocumentSnapshot snapshot = await _userDocRef.get();
      data = snapshot.data;
    }
    _setProfileInfo(data);
    return true;
  }

  _showSnackBar(String text, {Duration duration, bool isError = false}) {
    SnackBar sb;
    if (isError) {
      sb = SnackBar(
        content: Row(
          children: <Widget>[
            Icon(Icons.error),
            Text(text),
          ],
        ),
        duration: duration ?? _snackBarDefaultDuration,
      );
    } else {
      sb = SnackBar(
        content: Text(text),
        duration: duration ?? _snackBarDefaultDuration,
      );
    }
    Scaffold.of(context).showSnackBar(sb);
  }

  _hideSnackBar() {
    Scaffold.of(context).hideCurrentSnackBar();
  }

  _uploadProfilePhoto() async {
    try {
      ImageSource _imageSource;
      await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.5),
          context: context,
          builder: (context) =>
              ImageSourceBottomSheet((ImageSource imageSource) {
                _imageSource = imageSource;
              }));
      if (_imageSource != null) {
        ProfileInfo info =
            await ChatService.setProfilePhoto(_profileInfo, _userDocRef, () {
          _showSnackBar('Uploading profile photo...',
              duration: Duration(minutes: 1));
        }, _imageSource);
        if (info != null) {
          FileHandler.instance
              .setProfileInfo(OTPAuth.currentUser.uid, ProfileInfo.toMap(info));
          _hideSnackBar();
        }
      }
    } catch (e) {
      _hideSnackBar();
      _showSnackBar('Some error occured while uploading photo.', isError: true);
    }
  }

  _setProfileInfo(Map<String, dynamic> data) {
    _profileInfo = ProfileInfo.fromMap(data);
    _displayNameController.text = _profileInfo.displayName;
    _dobController.text = _profileInfo.dateOfBirth != null
        ? ProfileInfo.formatter.format(
            DateTime.fromMillisecondsSinceEpoch(_profileInfo.dateOfBirth))
        : '';
    _phoneNumberController.text = widget.user.phoneNumber;
  }

  _updateProfileInfo() {
    try {
      _showSnackBar('Updating...');
      _profileInfo.dateOfBirth = ProfileInfo.formatter
          .parse(_dobController.text)
          .millisecondsSinceEpoch;
      _profileInfo.displayName = _displayNameController.text.trim();
      Map<String, dynamic> data = ProfileInfo.toMap(_profileInfo);
      FileHandler.instance.setProfileInfo(OTPAuth.currentUser.uid, data);
      _userDocRef.updateData(data);
      _hideSnackBar();
      _showSnackBar('Updated');
    } catch (e) {
      _hideSnackBar();
      _showSnackBar('Some error occured while updating profile info.',
          isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.maxFinite,
          color: AppColorPallete.color,
          child: HeaderText(
            "Profile",
            align: TextAlign.left,
            size: 40,
          ),
        ),
      ),
      body: FutureBuilder(
          future: _getProfileInfo(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: 200,
                        child: Center(
                          child: Material(
                              borderRadius: BorderRadius.circular(75),
                              elevation: 5,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 75,
                                    backgroundColor: Colors.white,
                                    child: ClipOval(
                                      child: NetworkOrFileImage(
                                        _profileInfo.photoUrl,
                                        null,
                                        _profileInfo.fileName,
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: GestureDetector(
                                        onTap: () async {
                                          await _uploadProfilePhoto();
                                        },
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 5,
                                                  color: Colors.grey,
                                                )
                                              ],
                                              color: AppColorPallete.color,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Icon(
                                            Icons.edit,
                                            color: AppColorPallete.textColor,
                                            size: 16,
                                          ),
                                        )),
                                  )
                                ],
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 50),
                        child: Material(
                          elevation: 5,
                          color: AppColorPallete.color,
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: <Widget>[
                                  Material(
                                    elevation: 5,
                                    // margin: EdgeInsets.symmetric(vertical: 10),
                                    child: CTextFormField(
                                        controller: _displayNameController,
                                        prefixIcon: Icon(Icons.person),
                                        labelText: 'Name',
                                        validator: (val) => noe(val)
                                            ? 'Please enter your name'
                                            : null),
                                  ),
                                  Material(
                                    elevation: 5,
                                    // margin: EdgeInsets.symmetric(vertical: 10),
                                    child: CTextFormField(
                                      controller: _dobController,
                                      prefixIcon: Icon(Icons.calendar_today),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.date_range),
                                        onPressed: () async {
                                          final DateTime dateSelected =
                                              await showDateDialog(
                                            context: context,
                                            firstDate: DateTime(
                                                DateTime.now().year - 99),
                                            initialDate: DateTime.now(),
                                            lastDate: DateTime.now(),
                                          );
                                          if (dateSelected != null) {
                                            _dobController.text = ProfileInfo
                                                .formatter
                                                .format(dateSelected);
                                          }
                                        },
                                      ),
                                      labelText: 'Date of Birth',
                                      validator: (val) {
                                        try {
                                          ProfileInfo.formatter
                                              .parseStrict(val);
                                          return null;
                                        } catch (e) {
                                          return "Please choose correct date";
                                        }
                                      },
                                    ),
                                  ),
                                  Material(
                                    elevation: 5,
                                    // margin: EdgeInsets.symmetric(vertical: 10),
                                    child: CTextFormField(
                                        controller: _phoneNumberController,
                                        enabled: false,
                                        prefixIcon: Icon(Icons.contact_phone),
                                        labelText: 'Phone Number',
                                        onSaved: (val) => {},
                                        validator: (val) => null),
                                  ),
                                  Container(
                                    margin: EdgeInsetsDirectional.only(top: 15),
                                    child: MaterialButton(
                                      color: Colors.white,
                                      minWidth: double.infinity,
                                      elevation: 0,
                                      textColor: AppColorPallete.color,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      onPressed: () async {
                                        _formKey.currentState.save();
                                        if (_formKey.currentState.validate()) {
                                          await _updateProfileInfo();
                                        }
                                      },
                                      child: Text('Update'),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsetsDirectional.only(top: 15),
                                    child: MaterialButton(
                                      color: Colors.redAccent,
                                      minWidth: double.infinity,
                                      elevation: 0,
                                      textColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      onPressed: () async {
                                        widget._auth.signOut();
                                      },
                                      child: Text('Logout'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ConnectingPage();
          }),
    );
  }
}
