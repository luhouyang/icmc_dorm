import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIColor {
  final Color primaryBlue = const Color.fromARGB(255, 28, 37, 90);
  final Color secondaryBlue = const Color.fromARGB(255, 221, 227, 238);

  final Color primaryDarkRed = const Color.fromARGB(255, 125, 0, 0);
  final Color secondaryRed = const Color.fromARGB(255, 255, 59, 45);

  final Color primaryRed = const Color.fromARGB(255, 255, 64, 64);
  final Color primaryGreen = const Color.fromARGB(255, 64, 255, 64);
  final Color brightBlue = const Color.fromARGB(255, 0, 225, 255);

  final Color white = const Color.fromARGB(255, 255, 255, 255);
  final Color darkGray = const Color.fromARGB(255, 90, 90, 90);
  final Color gray = const Color.fromARGB(255, 175, 175, 175);
  final Color mediumGray = const Color.fromARGB(255, 215, 215, 215);
  final Color lightGray = const Color.fromARGB(255, 245, 245, 245);

  final Color blueBlack = const Color.fromARGB(255, 14, 19, 45);
  final Color orangeBlack = const Color.fromARGB(255, 30, 5, 5);

  // Transparent Colors
  final Color transparentPrimaryBlue = const Color.fromARGB(255, 201, 214, 232);
  final Color transparentSecondaryBlue = const Color.fromARGB(255, 213, 246, 251);

  final Color transparentPrimaryOrange = const Color.fromARGB(255, 255, 197, 183);
  final Color transparentSecondaryOrange = const Color.fromARGB(255, 255, 215, 200);
}

final ThemeData lightTheme = ThemeData(
  primaryColor: UIColor().primaryDarkRed,
  scaffoldBackgroundColor: UIColor().lightGray,
  appBarTheme: AppBarTheme(color: UIColor().primaryDarkRed, foregroundColor: UIColor().darkGray),
  iconTheme: IconThemeData(color: UIColor().primaryRed),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryDarkRed,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    ),
    displayMedium: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryDarkRed,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    displaySmall: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryDarkRed,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    headlineMedium: GoogleFonts.inter(
      textStyle: TextStyle(color: UIColor().white, fontSize: 20, fontWeight: FontWeight.w500),
    ),
    headlineSmall: GoogleFonts.inter(
      textStyle: TextStyle(color: UIColor().white, fontSize: 16, fontWeight: FontWeight.w500),
    ),
    bodyMedium: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().primaryDarkRed)),
    labelLarge: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().primaryDarkRed)),
    labelSmall: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().gray)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: UIColor().lightGray,
      backgroundColor: UIColor().primaryDarkRed,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadowColor: UIColor().gray,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(UIColor().lightGray),
      backgroundColor: WidgetStatePropertyAll(UIColor().primaryDarkRed),
      shape: WidgetStatePropertyAll(
        ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      shadowColor: WidgetStatePropertyAll(UIColor().gray),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(cursorColor: UIColor().darkGray),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: UIColor().transparentPrimaryOrange,
    hintStyle: TextStyle(fontSize: 16, color: UIColor().primaryDarkRed),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: UIColor().primaryDarkRed)),
    border: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: UIColor().primaryDarkRed),
    ),
    hoverColor: UIColor().transparentSecondaryOrange,
    errorStyle: TextStyle(color: UIColor().primaryRed),
    floatingLabelStyle: TextStyle(color: UIColor().primaryDarkRed),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: UIColor().transparentPrimaryOrange,
    contentTextStyle: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().primaryDarkRed)),
  ),
  scrollbarTheme: ScrollbarThemeData(thumbColor: WidgetStatePropertyAll(UIColor().primaryDarkRed)),
  cardTheme: CardTheme(color: UIColor().lightGray, elevation: 3),
  highlightColor: UIColor().transparentSecondaryOrange,
  dividerTheme: DividerThemeData(color: UIColor().primaryDarkRed, thickness: 1.5),
  useMaterial3: true,
);
