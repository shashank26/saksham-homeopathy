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
  final MedicineInfo _medicineInfo = MedicineInfo();
  final FirebaseUser user;

  AddMedicineForm(this.user);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            child: HeaderText('Add Medicine'),
          ),
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
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime.now().add(Duration(days: 365)));
                  if (dateSelected != null) {
                    this._medicineInfo.datePrescribed = dateSelected.millisecondsSinceEpoch;
                    _dateController.text = this._medicineInfo.getDatePrescribed();
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
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Adding medicine to the list.'),
                ));
                _medicineInfo.uid = user.uid;
                await FirestoreCollection.addMedicine(OTPAuth.currentUser.uid)
                    .add(MedicineInfo.toMap(_medicineInfo));
                Scaffold.of(context).hideCurrentSnackBar();
                _nameController.text = '';
                _dateController.text = '';
                _dosageController.text = '';
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Added.'),
                ));
                // Navigator.pop(context);
              },
              color: AppColorPallete.color,
              minWidth: double.infinity,
              elevation: 0,
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
