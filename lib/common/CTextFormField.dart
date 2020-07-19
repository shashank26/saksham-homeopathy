import 'package:flutter/material.dart';

class CTextFormField extends StatefulWidget {
  // final GlobalKey<FormState> key;
  final String labelText;
  final void Function(String) onSaved;
  final String Function(String) validator;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final void Function() onTap;
  final TextEditingController controller;
  final bool enabled;

  CTextFormField(
      {this.enabled,
      this.controller,
      this.onTap,
      this.labelText,
      this.onSaved,
      this.validator,
      this.prefixIcon,
      this.suffixIcon});

  @override
  _CTextFormFieldState createState() => _CTextFormFieldState();
}

class _CTextFormFieldState extends State<CTextFormField> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _hasFocus = hasFocus;
        });
      },
      child: Material(
        elevation: _hasFocus ? 5 : 2,
        shadowColor: Color.fromARGB(255, 220, 220, 220),
        child: TextFormField(
          onSaved: widget.onSaved,
          enabled: widget.enabled,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            labelText: widget.labelText,
            border: OutlineInputBorder(borderSide: BorderSide.none),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
          ),
          validator: widget.validator,
          onTap: widget.onTap,
          controller: widget.controller,
        ),
      ),
    );
  }
}
