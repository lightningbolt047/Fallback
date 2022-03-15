import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../const.dart';
import '../../services/asset_mapping.dart';


class CustomTextField extends StatelessWidget {
  final String? labelText;
  final bool? filled;
  final Widget? prefix;
  final Function onChanged;
  final bool obscureText;
  const CustomTextField({Key? key,this.labelText, this.filled, this.obscureText=false, this.prefix, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        // contentPadding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
        fillColor: kDarkBackgroundColor,
        filled: filled,
        labelText: labelText,
        labelStyle: const TextStyle(
          color: kIconColor,
        ),
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(
          maxWidth: 48,
          maxHeight: 48
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kIconColor),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          // borderSide: const BorderSide(color: kIconColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: obscureText,
      onChanged: (value){
        onChanged(value);
      },
      textInputAction: TextInputAction.next,
      cursorHeight: 25,
      cursorColor: kIconColor,
      style: GoogleFonts.quicksand(
          fontSize: 20
      ),
    );
  }
}
