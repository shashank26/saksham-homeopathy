import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  ExpandableText(this.text);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  String visibleText;
  bool expand = false;

  @override
  void initState() {
    super.initState();
    visibleText =
        widget.text.length > 300 ? widget.text.substring(0, 300) : widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Linkify(
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                // throw 'Could not launch ${link.url}';
              }
            },
            text: expand ? widget.text : visibleText,
            style: TextStyle(
                color: AppColorPallete.textColor,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
        if (widget.text.length > 300)
          GestureDetector(
            onTap: () {
              setState(() {
                expand = !expand;
              });
            },
            child: Text(expand ? 'read less...' : 'read more...',
                style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}
