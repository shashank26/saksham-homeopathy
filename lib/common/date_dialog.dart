import 'package:flutter/material.dart';

import 'constants.dart';

Future<DateTime> showDateDialog(
    {@required BuildContext context,
    @required DateTime firstDate,
    @required DateTime initialDate,
    @required DateTime lastDate}) {
  return showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 99),
      initialDate: initialDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          child: child,
          data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(primary: AppColorPallete.color),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary)),
        );
      });
}
