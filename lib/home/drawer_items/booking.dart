import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/booking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class Booking extends StatefulWidget {
  final BookingService bookingService;
  Booking(this.bookingService);
  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> with SingleTickerProviderStateMixin {
  final List<DateTime> dateTimes = [];
  DateTime date = DateTime.now();
  SlotBooking booking = new SlotBooking();
  List<SlotBooking> currentBookings = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      booking.uid = widget.bookingService.userId;
      booking.slotDate = DateTime(date.year, date.month, date.day);
    });
    if (date.weekday == 1) {
      date = date.add(Duration(days: 1));
    }
  }

  bool _slotTimePast(SlotType slotType) {
    final currentDate = DateTime.now();
    final slotHourMinute = slotType.content.split(':');
    if (currentDate.isBefore(booking.slotDate)) {
      return false;
    }

    if (currentDate.hour < int.parse(slotHourMinute[0])) {
      return false;
    }

    if (currentDate.hour == int.parse(slotHourMinute[0]) &&
        currentDate.minute < int.parse(slotHourMinute[1].substring(0, 2))) {
      return false;
    }

    return true;
  }

  List<Widget> getSlots(slots) {
    final availableSlots = SlotType.values;
    if (slots.contains(booking.slotType)) {
      booking.slotType = null;
    }
    return availableSlots
        .map((e) => MaterialButton(
              child: Text(e.content),
              elevation: 5,
              color: booking.slotType == e
                  ? AppColorPallete.color
                  : AppColorPallete.backgroundColor,
              onPressed: (slots.contains(e) || _slotTimePast(e))
                  ? null
                  : () {
                      setState(() {
                        booking.slotType = e;
                      });
                    },
            ))
        .toList();
  }

  List<Widget> getCancellationWidgets(DocumentSnapshot doc) {
    SlotBooking booking = SlotBooking(
        slotType: SlotType.values[int.parse((doc.get('slotType').toString()))],
        slotDate: (doc.get('slotDate') as Timestamp).toDate(),
        uid: doc.get('uid').toString());
    return [
      Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text('You already have a booking for the selected day at ' +
            booking.slotType.content),
      ),
      MaterialButton(
        onPressed: () async {
          await widget.bookingService.cancelBooking(doc.reference);
          setState(() {});
        },
        child: Text(
          'Cancel',
          style: TextStyle(color: Colors.red),
        ),
      )
    ];
  }

  getBookingsForAdmin(List<DocumentSnapshot> docs) {
    List<Widget> bookings = [];
    List<SlotBooking> slotBookings =
        widget.bookingService.getSlotBookingList(docs);
    slotBookings.sort((b1, b2) => b1.slotType.index - b2.slotType.index);
    for (int i = 0; i < slotBookings.length; i++) {
      SlotBooking booking = slotBookings[i];
      bookings.add(
        MaterialButton(
          elevation: 5,
          color: AppColorPallete.backgroundColor,
          child: Text(booking.slotType.content),
          onPressed: () async {
            ProfileInfo info =
                await widget.bookingService.getUserInfo(booking.uid);
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, a1, a2) {
                  return AlertDialog(
                    content: Container(
                      child: Wrap(
                        direction: Axis.vertical,
                        children: [
                          Text('Name: ' + info.displayName),
                          Text('Contact: ' + info.phoneNumber),
                          Text('Time: ' + booking.slotType.content)
                        ],
                      ),
                    ),
                    actions: [
                      MaterialButton(
                        child: Text(
                          'Cancel Booking',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          await booking.ref.delete();
                          setState(() {});
                          Navigator.pop(_);
                        },
                      ),
                      MaterialButton(
                        child: Text('Dismiss'),
                        onPressed: () {
                          Navigator.pop(_);
                        },
                      )
                    ],
                  );
                }));
          },
        ),
      );
    }

    if (bookings.length == 0) {
      bookings.add(Center(child: Text('No Bookings for selected day.')));
    }
    return bookings;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: AppColorPallete.textColor),
          backgroundColor: AppColorPallete.backgroundColor,
          title: Container(
              color: AppColorPallete.backgroundColor,
              child: HeaderText(
                "Booking",
                align: TextAlign.left,
                size: 20,
              )),
        ),
        body: FutureBuilder<List<DocumentSnapshot>>(
            future: widget.bookingService.getCurrentBookings(booking.slotDate),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                final bookings =
                    widget.bookingService.getSlotBookingList(snapshot.data);

                List<DocumentSnapshot> hasBooking = snapshot.data
                    .where((element) => element.get('uid') == booking.uid)
                    .toList();

                final slots = bookings.map((e) => e.slotType).toList();

                return Stack(children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 50),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Theme(
                              data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(
                                      primary: AppColorPallete.color),
                                  buttonTheme: ButtonThemeData(
                                      textTheme: ButtonTextTheme.primary)),
                              child: CalendarDatePicker(
                                initialDate: date.isAfter(booking.slotDate)
                                    ? date
                                    : booking.slotDate,
                                firstDate: date,
                                lastDate: date.add(Duration(days: 7)),
                                onDateChanged: (date) {
                                  setState(() {
                                    booking.slotDate = date;
                                    booking.slotType = null;
                                  });
                                },
                                selectableDayPredicate: (date) {
                                  return date.weekday != 1;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (OTPAuth.isAdmin)
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Wrap(
                                        spacing: 5,
                                        children: this
                                            .getBookingsForAdmin(snapshot.data),
                                      ),
                                    ),
                                  if (!OTPAuth.isAdmin)
                                    Text(
                                      "NOTE: 10:15 AM booking is for new consultation only!",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  if (!OTPAuth.isAdmin)
                                    hasBooking.length > 0
                                        ? Column(
                                            children: this
                                                .getCancellationWidgets(
                                                    hasBooking[0]))
                                        : Wrap(
                                            spacing: 5,
                                            children: this.getSlots(slots),
                                          ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!OTPAuth.isAdmin)
                    hasBooking.length > 0
                        ? Container()
                        : Positioned(
                            bottom: 0,
                            child: MaterialButton(
                              height: 50,
                              disabledColor: Colors.grey,
                              color: AppColorPallete.color,
                              minWidth: MediaQuery.of(context).size.width,
                              child: Text('Book'),
                              onPressed: booking.slotDate != null &&
                                      booking.slotType != null
                                  ? () async {
                                      if (!_slotTimePast(booking.slotType) &&
                                          await widget.bookingService
                                              .confirmBooking(booking)) {
                                        setState(() {
                                          booking.slotType = null;
                                        });
                                        Scaffold.of(_).showSnackBar(SnackBar(
                                          content: Text('Booking successful!'),
                                        ));
                                      } else {
                                        setState(() {
                                          booking.slotType = null;
                                        });
                                        Scaffold.of(_).showSnackBar(SnackBar(
                                          content: Text('Slot not available!'),
                                        ));
                                      }
                                    }
                                  : null,
                            ),
                          ),
                ]);
              }
              return Container();
            }),
      ),
    );
  }
}

enum SlotType {
  SLOT_1015,
  SLOT_1130,
  SLOT_1145,
  SLOT_1200,
  SLOT_1215,
  SLOT_1230,
  SLOT_1245,
}

extension SlotTypeExtension on SlotType {
  String get content {
    switch (this) {
      case SlotType.SLOT_1015:
        return '10:15 AM';
      case SlotType.SLOT_1130:
        return '11:30 AM';
      case SlotType.SLOT_1145:
        return '11:45 AM';
      case SlotType.SLOT_1200:
        return '12:00 PM';
      case SlotType.SLOT_1215:
        return '12:15 PM';
      case SlotType.SLOT_1230:
        return '12:30 PM';
      case SlotType.SLOT_1245:
        return '12:45 PM';
      default:
        return null;
    }
  }
}

class SlotBooking {
  SlotType slotType;
  DateTime slotDate;
  String uid;
  DocumentReference ref;

  SlotBooking({this.slotType, this.slotDate, this.uid, this.ref});

  static SlotBooking fromMap(DocumentSnapshot snap) {
    Map map = snap.data();
    return SlotBooking(
        uid: map['uid'].toString(),
        slotType: SlotType.values[int.parse((map['slotType'].toString()))],
        slotDate: (map['slotDate'] as Timestamp).toDate(),
        ref: snap.reference);
  }

  static toMap(SlotBooking booking) {
    return {
      'uid': booking.uid,
      'slotType': booking.slotType.index,
      'slotDate': booking.slotDate
    };
  }
}
