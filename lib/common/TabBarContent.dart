import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saksham_homeopathy/common/constants.dart';

class TabBarContent extends StatefulWidget {
  final DateTime relatedDate;
  TabBarContent(this.relatedDate);

  @override
  _TabBarContentState createState() => _TabBarContentState();
}

class _TabBarContentState extends State<TabBarContent> {
  final DateFormat _formatter = DateFormat('hh:mm');
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final dateNow = DateTime(widget.relatedDate.year, widget.relatedDate.month,
        widget.relatedDate.day, 11, 30);
    return Material(
        child: ListView(
      children: [
        for (var i = 0; i < 6; i++)
          ListTile(
            selected: selectedIndex == i,
            selectedTileColor: AppColorPallete.color,
            onTap: () {
              setState(() {
                selectedIndex = i;
              });
            },
            title: InkWell(
              child: Text(
                _formatter.format(
                  dateNow.add(Duration(minutes: i * 15)),
                ),
                style:
                    TextStyle(color: AppColorPallete.textColor, fontSize: 18),
              ),
            ),
          )
      ],
    ));
  }
}
