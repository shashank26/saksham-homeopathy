import 'package:flutter/material.dart';

class CTextFormField extends StatefulWidget {
  // final GlobalKey<FormState> key;
  final String labelText;
  final void Function(String) onSaved;
  final String Function(String) validator;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final void Function() onTap;
  final void Function(String) onChanged;
  final TextEditingController controller;
  final bool enabled;
  final Widget prefix;
  final Widget suffixWidget;
  final int maxChars;
  final FloatingLabelBehavior floatingLabelBehavior;
  final bool autoFocus;

  CTextFormField(
      {this.autoFocus = false,
      this.enabled,
      this.controller,
      this.onTap,
      this.labelText,
      this.onSaved,
      this.validator,
      this.prefixIcon,
      this.suffixIcon,
      this.prefix,
      this.onChanged,
      this.suffixWidget,
      this.floatingLabelBehavior = FloatingLabelBehavior.never,
      this.maxChars});

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
          // _hasFocus = hasFocus;
        });
      },
      child: Material(
        elevation: _hasFocus ? 10 : 5,
        shadowColor: Color.fromARGB(255, 220, 220, 220),
        child: TextFormField(
          autofocus: widget.autoFocus,
          onSaved: widget.onSaved,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            prefix: widget.prefix,
            floatingLabelBehavior: widget.floatingLabelBehavior,
            labelText: widget.labelText,
            border: OutlineInputBorder(borderSide: BorderSide.none),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            suffix: widget.suffixWidget,
          ),
          style: TextStyle(fontSize: 18),
          maxLength: widget.maxChars,
          validator: widget.validator,
          onTap: widget.onTap,
          controller: widget.controller,
        ),
      ),
    );
  }
}
