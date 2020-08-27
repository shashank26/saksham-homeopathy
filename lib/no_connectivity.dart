import 'package:flutter/material.dart';

import 'common/constants.dart';
import 'common/header_text.dart';

class NoConnectivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Wrap(
              children: <Widget>[
                Icon(
                  Icons.signal_cellular_connected_no_internet_4_bar,
                  color: AppColorPallete.textColor,
                  size: 50,
                ),
              ],
            ),
            HeaderText(
              'Please connect to internet.',
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
