import 'package:flutter/material.dart';
import '../../const.dart';


class CustomTextField extends StatelessWidget {
  final String? labelText;
  final bool? filled;
  final Widget? prefix;
  final Function? onChanged;
  final bool obscureText;
  final TextEditingController? controller;
  const CustomTextField({Key? key,this.labelText, this.filled, this.obscureText=false, this.prefix,this.onChanged,this.controller}) : super(key: key);

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
      controller: controller,
      obscureText: obscureText,
      onChanged: (value){
        if(onChanged!=null){
          onChanged!(value);
        }
      },
      textInputAction: TextInputAction.next,
      cursorHeight: 25,
      cursorColor: kIconColor,
      style: const TextStyle(
        fontSize: 20
      ),
    );
  }
}
