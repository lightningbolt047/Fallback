import 'package:fallback/const.dart';
import 'package:fallback/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fallback',
      // showPerformanceOverlay: true,
      theme: ThemeData(
        useMaterial3: true,
        backgroundColor: kBackgroundColor,
        cardColor: kBackgroundColor,
        dialogBackgroundColor: kBackgroundColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kIconColor),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: kIconColor,
        ),
        appBarTheme: const AppBarTheme(
          color: kIconColor
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(kIconColor)
          ),
        ),
        toggleableActiveColor: kIconColor,
        textTheme: TextTheme(
          headline1: GoogleFonts.quicksand(),
          headline2: GoogleFonts.quicksand(),
          headline3: GoogleFonts.quicksand(),
          headline4: GoogleFonts.quicksand(),
          headline5: GoogleFonts.quicksand(),
          headline6: GoogleFonts.quicksand(),
          subtitle1: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
          subtitle2: GoogleFonts.quicksand(),
          bodyText1: GoogleFonts.quicksand(),
          bodyText2: GoogleFonts.quicksand(),
          caption: GoogleFonts.quicksand(),
          button: GoogleFonts.quicksand(),
        )
      ),
      home: MainLayout(),
    );
  }
}