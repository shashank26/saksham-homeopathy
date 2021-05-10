import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/date_dialog.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/models/medicine_info.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class AddMedicineForm extends StatelessWidget {
  final _dateController = new TextEditingController(text: '');
  final _nameController = new TextEditingController(text: '');
  final _dosageController = new TextEditingController(text: '');
  final _endDateController = new TextEditingController(text: '');
  final MedicineInfo _medicineInfo = MedicineInfo();
  final User user;

  AddMedicineForm(this.user);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColorPallete.textColor),
        backgroundColor: AppColorPallete.backgroundColor,
        title: Container(
          color: AppColorPallete.backgroundColor,
          child: HeaderText(
            "Add Medicine",
            align: TextAlign.left,
            size: 40,
          ),
        ),
      ),
      body: Container(
        color: AppColorPallete.color,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: CTextFormField(
                        controller: _nameController,
                        labelText: 'Name',
                        onSaved: (val) => this._medicineInfo.name = val,
                        validator: (val) => null),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: CTextFormField(
                        controller: _dosageController,
                        labelText: 'Dosage',
                        onSaved: (val) => this._medicineInfo.dosage = val,
                        validator: (val) => null),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: CTextFormField(
                      controller: _dateController,
                      labelText: 'Prescribed Date',
                      onSaved: (val) => {},
                      validator: (val) => null,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: () async {
                          final DateTime dateSelected = await showDateDialog(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(Duration(days: 365)));
                          if (dateSelected != null) {
                            this._medicineInfo.datePrescribed =
                                dateSelected.millisecondsSinceEpoch;
                            _dateController.text =
                                this._medicineInfo.getDatePrescribed();
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: CTextFormField(
                      controller: _endDateController,
                      labelText: 'End Date',
                      onSaved: (val) => {},
                      validator: (val) => null,
                      onChanged: (val) {
                        this._medicineInfo.setEndDate(val);
                      },
                      suffixIcon: IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: () async {
                          final DateTime dateSelected = await showDateDialog(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(Duration(days: 365)));
                          if (dateSelected != null) {
                            this._medicineInfo.endDate =
                                dateSelected.millisecondsSinceEpoch;
                            _endDateController.text =
                                this._medicineInfo.getEndDate();
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: MaterialButton(
                      child: Text('Add'),
                      onPressed: () async {
                        _formKey.currentState.save();
                        if (this._medicineInfo.isEndDateValid() &&
                            !noe(this._medicineInfo.name) &&
                            !noe(this._medicineInfo.dosage) &&
                            !noe(this._medicineInfo.getDatePrescribed())) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Adding medicine to the list.'),
                          ));
                          _medicineInfo.uid = user.uid;
                          await FirestoreCollection.addMedicine(
                                  OTPAuth.currentUser.uid)
                              .add(MedicineInfo.toMap(_medicineInfo));
                          Scaffold.of(context).hideCurrentSnackBar();
                          _nameController.text = '';
                          _dateController.text = '';
                          _dosageController.text = '';
                          _endDateController.text = '';
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Added.'),
                          ));
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Please fill all necessary details [Name, Dosage, Date Prescribed] or a valid End date.'),
                          ));
                        }
                      },
                      color: AppColorPallete.backgroundColor,
                      minWidth: double.infinity,
                      elevation: 0,
                      textColor: AppColorPallete.color,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
