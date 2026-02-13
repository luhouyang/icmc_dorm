import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/states/constants.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';

class TextInputs {
  bool isNumeric(String str) {
    RegExp numeric = RegExp(r'^-?[0-9]+$');
    return numeric.hasMatch(str);
  }

  emailVerify(value) {
    return EmailValidator.validate(value ?? "") ? null : "Please enter a valid email";
  }

  passwordVerify(value) {
    return (value == null || value.isEmpty || value.length < 6)
        ? "Please enter password of at least 6 length"
        : null;
  }

  textVerify(value) {
    return (value == null || value.isEmpty) ? "Please enter a valid text" : null;
  }

  intNumberVerify(value) {
    return (value == null || value.isEmpty || !isNumeric(value)) ? "Please enter an integer" : null;
  }

  Widget editingTextWidget({
    required Function validator,
    required TextEditingController controller,
    bool expands = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child:
          expands
              ? SizedBox(
                height: Constants().inputTextHeight * 7,
                child: TextFormField(
                  cursorColor: UIColor().primaryDarkRed,
                  enabled: enabled,
                  expands: expands,
                  minLines: null,
                  maxLines: null,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  validator: (value) => validator(value),
                  controller: controller,
                  style: TextStyle(color: UIColor().primaryDarkRed),
                  textAlignVertical: TextAlignVertical.top,
                ),
              )
              : TextFormField(
                cursorColor: UIColor().primaryDarkRed,
                enabled: enabled,
                autovalidateMode: AutovalidateMode.onUnfocus,
                validator: (value) => validator(value),
                controller: controller,
                style: TextStyle(color: UIColor().primaryDarkRed),
              ),
    );
  }

  Widget inputTextWidget({
    required String hint,
    required Function validator,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: TextFormField(
        cursorColor: UIColor().darkGray,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) => validator(value),
        controller: controller,
        style: TextStyle(color: UIColor().darkGray),
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }

  Widget inputNumberWidget({
    required String hint,
    required Function validator,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: TextFormField(
        cursorColor: UIColor().darkGray,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) => validator(value),
        controller: controller,
        style: TextStyle(color: UIColor().darkGray),
        decoration: InputDecoration(hintText: hint),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget obscureInputTextWidget({
    required String hint,
    required Function validator,
    required TextEditingController controller,
    required Function getFunc,
    required Function setFunc,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: TextFormField(
        cursorColor: UIColor().darkGray,
        obscureText: getFunc(),
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) => validator(value),
        controller: controller,
        style: TextStyle(color: UIColor().darkGray),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              getFunc() ? Icons.visibility : Icons.visibility_off,
              // color: UIColor().darkGray,
            ),
            onPressed: () {
              setFunc();
            },
          ),
          hintText: hint,
        ),
      ),
    );
  }
}
