import 'package:intl/intl.dart';

class MedicineInfo {
  String _name;
  String _dosage;
  int _datePrescribed;
  String _uid;
  final DateFormat _formatter = DateFormat('dd-MMM-yyyy');

  MedicineInfo();

  MedicineInfo._(name, dosage, datePrescribed, uid) {
    this._name = name;
    this._dosage = dosage;
    this._datePrescribed = datePrescribed;
    this._uid = uid;
  }

  String get uid => _uid;
  String get name => _name;
  String get dosage => _dosage;

  String getDatePrescribed() {
    return _formatter.format(DateTime.fromMillisecondsSinceEpoch(_datePrescribed));
  }

  set name(value) {
    _name = value;
  }

  set uid(value) {
    _uid = value;
  }

  set dosage(value) {
    _dosage = value;
  }

  set datePrescribed(int value) {
    _datePrescribed = value;
  }

  static Map<String, dynamic> toMap(MedicineInfo info) {
    return {
      'name': info.name,
      'dosage': info.dosage,
      'datePrescribed': info._datePrescribed,
      'uid' : info.uid
    };
  }

  static MedicineInfo fromMap(Map json) {
    return new MedicineInfo._(
        json['name'], json['dosage'], json['datePrescribed'], json['uid']);
  }
}
