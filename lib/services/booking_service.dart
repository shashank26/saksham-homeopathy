import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/home/drawer_items/booking.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';

import 'otp_auth.dart';

class BookingService {
  CollectionReference _bookingCollection;
  String userId;
  BookingService() {
    this._bookingCollection = FirestoreCollection.bookings();
    FileHandler fh = FileHandler.instance;
    this.userId = OTPAuth.currentUser.uid;
    if (OTPAuth.isAdmin) {
      this.purgeData();
    }
  }

  purgeData() async {
    DateTime date = DateTime.now();
    QuerySnapshot snapshot = await this
        ._bookingCollection
        .where('slotDate',
            isLessThan: DateTime(date.year, date.month, date.day))
        .get();
    snapshot.docs.forEach((element) {
      element.reference.delete();
    });
  }

  Future<List<DocumentSnapshot>> getCurrentBookings(DateTime date,
      {SlotType slotType}) async {
    if (slotType == null) {
      QuerySnapshot snapshot =
          await _bookingCollection.where('slotDate', isEqualTo: date).get();
      return snapshot.docs.toList();
    } else {
      QuerySnapshot snapshot = await _bookingCollection
          .where('slotDate', isEqualTo: date)
          .where('slotType', isEqualTo: slotType.index)
          .get();
      return snapshot.docs.toList();
    }
  }

  List<SlotBooking> getSlotBookingList(List<DocumentSnapshot> docs) {
    return docs.map((e) => SlotBooking.fromMap(e)).toList();
  }

  Future<bool> isBookingValid(SlotBooking booking) async {
    List<SlotBooking> bookings = this.getSlotBookingList(await this
        .getCurrentBookings(booking.slotDate, slotType: booking.slotType));
    return bookings.length == 0;
  }

  Future<bool> confirmBooking(SlotBooking booking) async {
    try {
      if (await this.isBookingValid(booking)) {
        await this._bookingCollection.add(SlotBooking.toMap(booking));
        return true;
      }
    } on Exception catch (e) {
      print(e);
    }
    return false;
  }

  Future<ProfileInfo> getUserInfo(String uid) async {
    final data = (await FirestoreCollection.userInfo(uid).get()).data();
    return ProfileInfo.fromMap(data);
  }

  Future<bool> cancelBooking(DocumentReference ref) async {
    await ref.delete();
    return true;
  }
}
