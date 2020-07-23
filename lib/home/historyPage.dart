import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/home/addMedicine.dart';
import 'package:saksham_homeopathy/home/medicineHistoryTile.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class HistoryView extends StatefulWidget {
  final FirebaseUser user;
  final String uid;
  HistoryView({this.user, this.uid});

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  Stream<QuerySnapshot> _historyStream;

  @override
  initState() {
    super.initState();
    _historyStream = FirestoreCollection.addMedicine
        .where('uid', isEqualTo: widget.uid)
        .snapshots();
  }

  void _settingModal(context) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: AddMedicineForm(widget.user),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorPallete.color,
        floatingActionButton: Visibility(
          visible: !OTPAuth.isAdmin,
          child: FloatingActionButton(
            onPressed: () {
              _settingModal(context);
            },
            child: Icon(
              Icons.add,
              color: AppColorPallete.color,
            ),
            backgroundColor: Colors.white,
          ),
        ),
        body: Column(
          children: <Widget>[
            Material(
              elevation: 5,
              child: Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  color: AppColorPallete.color,
                  child: HeaderText(
                    "History",
                    align: TextAlign.left,
                    size: 40,
                  )),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: _historyStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length > 0) {
                        final List<DocumentSnapshot> medicineInfoList =
                            snapshot.data.documents;
                        return ListView.builder(
                          itemCount: medicineInfoList.length,
                          itemBuilder: (context, index) {
                            return HistoryTile(
                                medicineInfoList.elementAt(index));
                          },
                        );
                      } else {
                        return Center(child: HeaderText('No Medicines added.'));
                      }
                    }
                    return Center(child: HeaderText('Loading...'));
                  }),
            ),
          ],
        ));
  }
}
