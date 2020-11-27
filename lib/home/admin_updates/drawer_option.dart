import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';

class DrawerOption extends StatelessWidget {
  final Function _navigate;
  final String _text;

  DrawerOption(this._text, this._navigate);

  @override
  Widget build(BuildContext context) {
    return Material(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      _navigate();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: AppColorPallete.textColor),
                      ),
                    ),
                  ),
                );
  }
  
}
