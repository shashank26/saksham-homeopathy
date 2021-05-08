import 'package:flutter/material.dart';

import 'constants.dart';

Future<DateTime> showDateDialog(
    {@required BuildContext context,
    DateTime firstDate,
    @required DateTime initialDate,
    @required DateTime lastDate,
    bool Function(DateTime) selectableDayPredicate}) {
      firstDate ?? DateTime(DateTime.now().year - 99);
  return showDatePicker(
      context: context,
      firstDate: firstDate,
      initialDate: initialDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
      selectableDayPredicate: selectableDayPredicate,
      builder: (context, child) {
        return Theme(
          child: child,
          data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(primary: AppColorPallete.color),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary)),
        );
      });
}
