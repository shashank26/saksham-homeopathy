import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';

class Subscriptions extends StatelessWidget {
  final List<Map> _numbers;
  final TextEditingController _numberController = TextEditingController();
  Subscriptions(this._numbers);

  isValidNumber() {
    final numb = _numberController.value.text;
    return !noe(numb) &&
        numb.length == 10 &&
        _numbers.indexWhere(
                (element) => element['phoneNumber'] == '+91' + numb) ==
            -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorPallete.backgroundColor,
        iconTheme: IconThemeData(color: AppColorPallete.textColor),
        title: HeaderText('Subscriptions'),
      ),
      body: ListView.builder(
          itemCount: _numbers.length,
          itemBuilder: (context, index) {
            final subscription = _numbers[index];
            return DecoratedBox(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppColorPallete.textColor, width: 1))),
              child: InkWell(
                customBorder:
                    Border(bottom: BorderSide(color: Colors.black, width: 2)),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FlatButton(
                              color: AppColorPallete.backgroundColor,
                              child: Text('Delete'),
                              onPressed: () async {
                                DocumentReference ref =
                                    subscription['documentReference'];
                                await ref.delete();
                                _numbers.remove(subscription);
                              },
                            )
                          ],
                        );
                      });
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    subscription['phoneNumber'].toString(),
                    style: TextStyle(
                        fontSize: 16, color: AppColorPallete.textColor),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
