import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/models/medicine_info.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class HistoryTile extends StatelessWidget {
  final DocumentSnapshot info;
  HistoryTile(this.info);

  @override
  Widget build(BuildContext context) {
    MedicineInfo mInfo = MedicineInfo.fromMap(info.data);
    return Material(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    HeaderText(mInfo.datePrescribed, size: 20),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Name: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          mInfo.name,
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16),
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Dosage: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          mInfo.dosage,
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !OTPAuth.isAdmin,
                child: Container(
                  width: 50,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: HeaderText('Delete'),
                              content: Text(
                                'Delete this medicine from the list?',
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  textColor: Colors.redAccent,
                                  child: Text('Delete'),
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        child: CustomDialog('Deleting...'));
                                    await info.reference.delete();
                                    int count = 0;
                                    Navigator.popUntil(context, (route) {
                                      return count++ == 2;
                                    });
                                  },
                                ),
                                FlatButton(
                                  textColor: Colors.black,
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
