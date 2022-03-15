import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenHeaderText extends StatelessWidget {
  final String text;
  const ScreenHeaderText({Key? key,required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,style: GoogleFonts.quicksand(
        fontSize: 30,
        fontWeight: FontWeight.w400
    ),);
  }
}
