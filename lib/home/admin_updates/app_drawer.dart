import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/home/admin_updates/testimonials.dart';
import 'package:saksham_homeopathy/home/admin_updates/user_stats.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class AppDrawer extends StatelessWidget {
  _navigate(context, Widget widget) {
    Navigator.pop(context);
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return widget;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          StreamBuilder<DocumentSnapshot>(
              stream:
                  FirestoreCollection.profileStream(OTPAuth.currentUser.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                ProfileInfo _info = ProfileInfo.fromMap(snapshot.data.data);
                return DrawerHeader(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                    child: Container(
                      color: AppColorPallete.color,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          NetworkOrFileImage(
                            _info.photoUrl,
                            null,
                            _info.fileName,
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                          ),
                          Container(
                              height: double.maxFinite,
                              width: double.maxFinite,
                              color: Colors.black.withOpacity(0.3),
                              child: Center(
                                  child: HeaderText(
                                'Hello,\n ${_info.displayName}',
                                color: AppColorPallete.backgroundColor,
                              ))),
                        ],
                      ),
                    ));
              }),
          Expanded(
            child: ListView(
              children: [
                Material(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      _navigate(context, Testimonials());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Testimonials',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: AppColorPallete.textColor),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: OTPAuth.isAdmin,
                  child: Material(
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        _navigate(context, UserStats());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'User stats',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: AppColorPallete.textColor),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
