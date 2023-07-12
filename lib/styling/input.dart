import 'package:flutter/material.dart';

InputDecoration inputFieldWithErrorMessage(String hint, String errorText, BuildContext context,) {
  //In order for error messages to appear on the RIGHT SIDE of the textformfield as required,
  //the widget must be wrapped in a DIRECTIONALITY widget with TextDirection.rtl

  return InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor,)
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Colors.blue,),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Colors.blue,),
    ),
    errorText: errorText.isEmpty? null : errorText,
    errorStyle: Theme.of(context).textTheme.labelSmall,

    filled: true,
    fillColor: Theme.of(context).secondaryHeaderColor,
    focusColor: Colors.white,
    hintText: hint,
    hintTextDirection: TextDirection.ltr,
    hintStyle: Theme.of(context).textTheme.bodyMedium,
    contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
  );
}