import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/home/admin_updates/subscriptions.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';

class UserStats extends StatelessWidget {
  final futureList = Future.wait(
      [FirestoreCollection.whiteList().get(), FirestoreCollection.getActiveUsers()]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColorPallete.textColor),
        backgroundColor: AppColorPallete.backgroundColor,
        title: HeaderText('User Stats'),
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: futureList,
        builder: (builder, snapshot) {
          if (!snapshot.hasData) {
            return ConnectingPage();
          }
          final activeUsers = snapshot.data[1].docs
              .map((e) => ProfileInfo.fromMap(e.data()))
              .where((element) => element.isAdmin != true)
              .toList();
          List<Map> whitelist = snapshot.data[0].docs
              .map((e) => { 'phoneNumber' : e.data()['phoneNumber'].toString(), 'documentReference' : e.reference})
              .toList();
          final subscribedActiveUsers = activeUsers
              .where((element) => whitelist.indexWhere((e) => e['phoneNumber'] == element.phoneNumber) != -1);
          final unsubscribedActiveUsers = activeUsers
              .where((element) => whitelist.indexWhere((e) => e['phoneNumber'] == element.phoneNumber) == -1);
          return ListView(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColorPallete.textColor, width: 1))),
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Active users: ${activeUsers.length}',
                      style: TextStyle(
                          color: AppColorPallete.textColor, fontSize: 18),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColorPallete.textColor, width: 1))),
                child: InkWell(
                  onTap: () {
                    // Navigator.of(context).push(PageRouteBuilder(
                    //     opaque: false,
                    //     pageBuilder: (BuildContext context, _, __) {
                    //       return Subscriptions(whitelist);
                    //     }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Subscriptions: ${whitelist.length}',
                      style: TextStyle(
                          color: AppColorPallete.textColor, fontSize: 18),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColorPallete.textColor, width: 1))),
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Subscribed active users: ${subscribedActiveUsers.length}',
                      style: TextStyle(
                          color: AppColorPallete.textColor, fontSize: 18),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColorPallete.textColor, width: 1))),
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Unsubscribed active users: ${unsubscribedActiveUsers.length}',
                      style: TextStyle(
                          color: AppColorPallete.textColor, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
