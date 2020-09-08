import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';

class PreviewProfile extends StatelessWidget {
  final ProfileInfo _profileInfo;
  PreviewProfile(this._profileInfo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPallete.color,
      appBar: AppBar(
        backgroundColor: AppColorPallete.backgroundColor,
        iconTheme: IconThemeData(color: AppColorPallete.textColor),
        title: HeaderText('Profile Info'),
      ),
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
                      onTap: () {
                        if (!noe(_profileInfo.fileName))
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Scaffold(
                                  appBar: AppBar(
                                    iconTheme: IconThemeData(color: AppColorPallete.textColor),
                                  ),
                                  body: Container(
                                    child: PhotoView(
                                        imageProvider: FileImage(
                                            FileHandler.instance.getRawFile(
                                                fileName:
                                                    _profileInfo.fileName))),
                                  ),
                                );
                              });
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 50),
                child: Material(
                  elevation: 5,
                  color: AppColorPallete.backgroundColor,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            child: Text(
                          noe(_profileInfo.displayName)
                              ? 'Name not updated'
                              : _profileInfo.displayName,
                          style: TextStyle(
                              color: AppColorPallete.textColor,
                              fontFamily: 'Raleway',
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline),
                        )),
                        Container(
                            child: Text(
                          _profileInfo.dateOfBirth != null
                              ? ProfileInfo.formatter.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      _profileInfo.dateOfBirth))
                              : 'Date of birth not updated!',
                          style: TextStyle(
                              color: AppColorPallete.textColor, fontSize: 18),
                        )),
                        Container(
                            child: Text(
                          _profileInfo.phoneNumber,
                          style: TextStyle(
                              color: AppColorPallete.textColor, fontSize: 18),
                        )),
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
}
