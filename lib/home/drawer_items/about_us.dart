import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/home/profile/profile_avatar.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPallete.backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColorPallete.textColor),
        backgroundColor: AppColorPallete.backgroundColor,
        title: Container(
            color: AppColorPallete.backgroundColor,
            child: HeaderText(
              "About Us",
              align: TextAlign.left,
              size: 20,
            )),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreCollection.aboutUs(),
            builder: (ctx, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Html(
                        data: snapshot.data.docs.first.get('content'),
                        style: {
                          'div': Style(
                            fontFamily: 'Times New Roman',
                          ),
                          'p': Style(
                            margin: EdgeInsets.only(top: 15),
                            fontSize: FontSize(20),
                            color: Colors.black87,
                          ),
                          'h2': Style(
                            fontSize: FontSize(35),
                            color: AppColorPallete.textColor,
                          )
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProfileAvatar(
                          OTPAuth.adminId,
                          radius: 50,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ConnectingPage();
            }),
      ),
    );
  }
}
