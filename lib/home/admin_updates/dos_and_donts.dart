import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';

class DosAndDonts extends StatelessWidget {
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
              "Do\'s and Don\'ts",
              align: TextAlign.left,
              size: 40,
            )),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirestoreCollection.dosAndDonts(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return ConnectingPage();
            }

            return SingleChildScrollView(
                          child: Html(
                data: snapshot.data.docs.first.data()['content'],
                style: {
                  'div': Style(
                    textAlign: TextAlign.left,
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Times New Roman',
                    color: Colors.black87
                  ),
                  'li': Style(
                    margin: EdgeInsets.only(top: 15)
                  )
                },
              ),
              
            );
          }
        ),
      ),
    );
  }
}