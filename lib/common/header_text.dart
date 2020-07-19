import 'package:flutter/cupertino.dart';

import 'constants.dart';

class HeaderText extends StatelessWidget {
  final String _text;
  final double size;
  HeaderText(this._text, {this.size: 30});
  @override
  Widget build(BuildContext context) {
    return Text(
      this._text,
      style: TextStyle(
        color: AppColorPallete.textColor,
        fontFamily: 'Raleway',
        fontSize: this.size,
        fontWeight: FontWeight.w900,
      ),
      textAlign: TextAlign.center,
    );
  }
}
