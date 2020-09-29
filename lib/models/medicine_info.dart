import 'package:intl/intl.dart';

class MedicineInfo {
  String _name;
  String _dosage;
  int _datePrescribed;
  int _endDate;
  String _uid;
  final DateFormat _formatter = DateFormat('dd-MMM-yyyy');

  MedicineInfo();

  MedicineInfo._(name, dosage, datePrescribed, uid, endDate) {
    this._name = name;
    this._dosage = dosage;
    this._datePrescribed = datePrescribed;
    this._uid = uid;
    this._endDate = endDate;
  }

  String get uid => _uid;
  String get name => _name;
  String get dosage => _dosage;

  String getDatePrescribed() {
    return _formatter
        .format(DateTime.fromMillisecondsSinceEpoch(_datePrescribed));
  }

  void setDatePrescribed(String date) {
    _datePrescribed = _formatter.parse(date).millisecondsSinceEpoch;
  }

  String getEndDate() {
    if (_endDate != null) {
      return _formatter.format(DateTime.fromMillisecondsSinceEpoch(_endDate));
    }
    return '';
  }

  void setEndDate(String date) {
    _endDate = _formatter.parse(date).millisecondsSinceEpoch;
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

  set endDate(int value) {
    _endDate = value;
  }

  isEndDateValid() {
    if (this._endDate != null &&
        (this._datePrescribed == null ||
            this._endDate < this._datePrescribed)) {
      return false;
    }
    return true;
  }

  static Map<String, dynamic> toMap(MedicineInfo info) {
    return {
      'name': info.name,
      'dosage': info.dosage,
      'datePrescribed': info._datePrescribed,
      'uid': info.uid,
      'endDate': info._endDate
    };
  }

  static MedicineInfo fromMap(Map json) {
    return new MedicineInfo._(json['name'], json['dosage'],
        json['datePrescribed'], json['uid'], json['endDate']);
  }
}
