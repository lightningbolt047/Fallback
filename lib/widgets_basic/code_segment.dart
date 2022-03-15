import 'package:fallback/const.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class CodeSegment extends StatelessWidget {

  final String codeSegment;
  const CodeSegment({Key? key,required this.codeSegment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: MaterialButton(
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25)
        ),
        elevation: 0,
        color: kCodeBackgroundColor,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: codeSegment));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied \"$codeSegment\" to clipboard")));
        },
        child: Text(codeSegment,style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),),
      ),
    );
  }
}
