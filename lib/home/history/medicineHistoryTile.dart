import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/models/medicine_info.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class HistoryTile extends StatelessWidget {
  final DocumentSnapshot info;
  HistoryTile(this.info);

  _deleteHandler(context) {
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
                      context: context, child: CustomDialog('Deleting...'));
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
  }

  @override
  Widget build(BuildContext context) {
    MedicineInfo mInfo = MedicineInfo.fromMap(info.data);
    return MaterialButton(
      color: Colors.white,
      onPressed: () {},
      onLongPress: () async {
        if (OTPAuth.isAdmin) {
          return;
        }
        await showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 100,
                child: Column(
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteHandler(context);
                        },
                        child: Text("Delete")),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel")),
                  ],
                ),
              );
            });
      },
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    HeaderText(mInfo.name, size: 20),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Start Date: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          mInfo.getDatePrescribed(),
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16),
                        ),
                      ],
                    ),
                    if (!noe(mInfo.getEndDate()))
                      Row(mainAxisSize: MainAxisSize.max, children: [
                        Text(
                          'End Date: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          mInfo.getEndDate(),
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16),
                        )
                      ]),
                    if (!noe(mInfo.getEndDate()))
                      Row(mainAxisSize: MainAxisSize.max, children: [
                        Text(
                          'Number of Days: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          mInfo.getDays(),
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16),
                        )
                      ]),
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
            ]),
      ),
    );
  }
}
