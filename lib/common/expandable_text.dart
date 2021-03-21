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
  
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    if (noe(widget.text)) {
      return Container();
    }
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
            text: expand ? widget.text : widget.text.length > 300 ? widget.text.substring(0, 300) : widget.text,
            style: TextStyle(
              fontFamily: 'Roboto',
                color: Color(0xFF444444),
                fontSize: 18,
                fontWeight: FontWeight.w400)),
        if (widget.text.length > 300)
          GestureDetector(
            onTap: () {
              setState(() {
                expand = !expand;
              });
            },
            child: Text(expand ? 'read less...' : 'read more...',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 17,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w400)),
          ),
      ],
    );
  }
}
