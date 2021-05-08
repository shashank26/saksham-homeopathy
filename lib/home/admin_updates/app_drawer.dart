import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/home/drawer_items/about_us.dart';
import 'package:saksham_homeopathy/home/drawer_items/booking.dart';
import 'package:saksham_homeopathy/home/drawer_items/certifications.dart';
import 'package:saksham_homeopathy/home/drawer_items/dos_and_donts.dart';
import 'package:saksham_homeopathy/home/drawer_items/testimonials.dart';
import 'package:saksham_homeopathy/home/drawer_items/user_stats.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/booking_service.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'drawer_option.dart';

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
                DrawerOption('About Us', () => _navigate(context, AboutUs())),
                DrawerOption('Do\'s and Don\'ts', () => _navigate(context, DosAndDonts())),
                DrawerOption('Testimonials', () => _navigate(context, Testimonials())),
                DrawerOption('Awards and Accolades', () => _navigate(context, Certifications())),
                DrawerOption('Booking', () => _navigate(context, Booking(new BookingService()))),
                Visibility(
                  visible: OTPAuth.isAdmin,
                  child: DrawerOption('User Stats', () => _navigate(context, UserStats())),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
