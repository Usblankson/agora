import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

Widget customButton(
  String text,
  bool isJoined,
  VoidCallback onPressed,
  Color color,
) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      foregroundColor: isJoined ? Pallete.white : Pallete.primary,
      backgroundColor: isJoined ? Pallete.error : color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      disabledForegroundColor: Colors.grey.withOpacity(0.38),
      disabledBackgroundColor: Colors.grey.withOpacity(0.12),
      minimumSize: const Size(double.infinity, 45),
    ),
    child:
        Text(text, style: const TextStyle(fontSize: 16, color: Pallete.white)),
  );
}

Widget customTextField(
  String hintText,
  TextEditingController? controller,
  String? Function(String?)? validator,
  bool enabled,
  Color color,
) {
  return TextFormField(
      controller: controller,
      cursorColor: Pallete.primary,
      enabled: enabled,
      validator:validator,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Pallete.grey,
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Pallete.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Pallete.primary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Pallete.primary),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Pallete.error),
        ),
      ));
}
