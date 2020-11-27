import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/home/history/addMedicine.dart';
import 'package:saksham_homeopathy/home/history/medicineHistoryTile.dart';
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
  List<DocumentSnapshot> medicineInfoList = [];
  List<DocumentSnapshot> medicineSearchResult = [];
  bool isSearching = false;
  String pageTitle = "History";

  @override
  initState() {
    super.initState();
    if (OTPAuth.isAdmin) {
      _historyStream = _historyStream =
          FirestoreCollection.addMedicine(widget.uid)
              .orderBy('datePrescribed')
              .snapshots();
      return;
    }

    _historyStream = FirestoreCollection.addMedicine(widget.uid)
        .where('datePrescribed', isGreaterThan: DateTime.now().subtract(Duration(days: 40)).millisecondsSinceEpoch)
        .orderBy('datePrescribed')
        .snapshots();
  }

  void _settingModal(context) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return AddMedicineForm(widget.user);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColorPallete.backgroundColor,
          iconTheme: IconThemeData(color: AppColorPallete.textColor),
          title: Container(
            width: double.maxFinite,
            color: AppColorPallete.backgroundColor,
            child: HeaderText(
              "History",
              align: TextAlign.left,
              size: 40,
            ),
          ),
          actions: [
            IconButton(
              icon: isSearching ? Icon(Icons.close) : Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  medicineSearchResult = medicineInfoList;
                });
              },
              color: AppColorPallete.textColor,
              iconSize: 30,
            )
          ],
        ),
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
        body: Padding(
          padding: const EdgeInsets.only(top : 8.0),
          child: Column(
            children: <Widget>[
              Visibility(
                visible: isSearching,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                  child: Column(
                    children: [
                      CTextFormField(
                        autoFocus: true,
                        prefixIcon: Icon(Icons.search),
                        onChanged: (val) {
                          if (!noe(val)) {
                            setState(() {
                              medicineSearchResult = medicineInfoList
                                  .where((element) => element.data['name']
                                      .toString().toLowerCase()
                                      .startsWith(val.toLowerCase()))
                                  .toList();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                    stream: _historyStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.documents.length > 0) {
                          medicineInfoList = snapshot.data.documents;
                          return ListView.builder(
                            itemCount: isSearching
                                ? medicineSearchResult.length
                                : medicineInfoList.length,
                            itemBuilder: (context, index) {
                              return isSearching
                                  ? HistoryTile(
                                      medicineSearchResult.elementAt(index))
                                  : HistoryTile(
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
          ),
        ));
  }
}
