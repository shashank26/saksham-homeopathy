import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user;

  ProfilePage(this.user);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController(text: '');
  final _ageController = TextEditingController(text: '');
  final _phoneNumberController = TextEditingController(text: '');
  ProfileInfo _profileInfo;
  DocumentReference _userDocRef;
  Stream<DocumentSnapshot> _profileStream;
  final _snackBarDefaultDuration = Duration(seconds: 4);

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
      await ChatService.setProfilePhoto(_profileInfo, _userDocRef, () {
        _showSnackBar('Uploading profile photo...',
            duration: Duration(minutes: 1));
      });
      _hideSnackBar();
    } catch (e) {
      _hideSnackBar();
      _showSnackBar('Some error occured while uploading photo.', isError: true);
    }
  }

  _setProfileInfo(DocumentSnapshot _snapshot) {
    _profileInfo = ProfileInfo.fromMap(_snapshot.data);
    _displayNameController.text = _profileInfo.displayName;
    _ageController.text = _profileInfo.age;
    _phoneNumberController.text = widget.user.phoneNumber;
    _userDocRef = _snapshot.reference;
  }

  _updateProfileInfo() {
    try {
      _showSnackBar('Updating...');
      _userDocRef.updateData(ProfileInfo.toMap(_profileInfo));
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
    _profileStream = FirebaseStreams.profileStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _profileStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _setProfileInfo(snapshot.data);
            return Scaffold(
              backgroundColor: AppColorPallete.color,
              body: SingleChildScrollView(
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
                            child: GestureDetector(
                              onTap: () async {
                                await _uploadProfilePhoto();
                              },
                              child: CircleAvatar(
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
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(0, 200, 200, 200),
                              blurRadius: 10.0,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: CTextFormField(
                                      controller: _displayNameController,
                                      labelText: 'Name',
                                      onSaved: (val) =>
                                          _profileInfo.displayName = val,
                                      validator: (val) => null),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: CTextFormField(
                                      controller: _ageController,
                                      labelText: 'Age',
                                      onSaved: (val) => _profileInfo.age = val,
                                      validator: (val) => null),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: CTextFormField(
                                      controller: _phoneNumberController,
                                      enabled: false,
                                      labelText: 'Phone Number',
                                      onSaved: (val) => {},
                                      validator: (val) => null),
                                ),
                                Container(
                                  margin: EdgeInsetsDirectional.only(top: 15),
                                  child: MaterialButton(
                                    color: AppColorPallete.color,
                                    minWidth: double.infinity,
                                    elevation: 0,
                                    textColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 15),
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
                                    padding: EdgeInsets.symmetric(vertical: 15),
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
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(child: HeaderText(''));
        });
  }
}
