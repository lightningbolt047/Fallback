import 'package:fallback/const.dart';
import 'package:flutter/material.dart';

class CodeSegmentInput extends StatelessWidget {
  final Function? onChanged;
  final bool? isLastField;
  final TextEditingController? controller;

  const CodeSegmentInput({Key? key,this.onChanged,this.isLastField,this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 1,
      color: kCodeBackgroundColor,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 125,
          maxHeight: 50
        ),
        margin: const EdgeInsets.all(4),
        child: TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.transparent)
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.transparent)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.transparent)
            ),
            fillColor: kCodeBackgroundColor,
            filled: true,
          ),
          controller: controller,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          cursorColor: kIconColor,
          cursorHeight: 24,
          textInputAction: (isLastField==null || !isLastField!)?TextInputAction.next:TextInputAction.done,
          onChanged: (value){
            if(onChanged!=null){
              onChanged!(value);
            }
          },
        ),
      ),
    );
  }
}
