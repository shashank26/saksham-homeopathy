import 'package:flutter/cupertino.dart';

import 'constants.dart';

class HeaderText extends StatelessWidget {
  final String _text;
  final double size;
  final TextAlign align;
  final Color color;
  final bool underline;
  HeaderText(this._text, {this.size: 30, this.align: TextAlign.center, this.color: AppColorPallete.textColor, this.underline: false});
  @override
  Widget build(BuildContext context) {
    return Text(
      this._text,
      style: TextStyle(
        color: this.color,
        fontFamily: 'Raleway',
        fontSize: this.size,
        fontWeight: FontWeight.w900,
        decoration: underline ? TextDecoration.underline : TextDecoration.none
      ),
      textAlign: this.align,
    );
  }
}
