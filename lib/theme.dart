import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primary = Color(0xFF0D6766);
const Color secondary = Color(0xFF113A3A);
const Color text = Color(0xFFFFFFFF);
const Color accent = Color(0xFF4FE0B5);
const Color attention = Color(0xFFF03535);
const Color surface = Color(0xFF28292F);
const Color background = Color(0xFF191A1F);

final ThemeData myTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: text,
      primaryContainer: surface,
      onPrimaryContainer: text,
      secondary: secondary,
      onSecondary: text,
      tertiary: accent,
      onTertiary: text,
      tertiaryContainer: accent,
      error: attention,
      errorContainer: attention,
      onError: text,
      surface: surface,
      onSurface: text,
      shadow: background,
      background: background,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: text),
      displayMedium: GoogleFonts.inter(fontSize: 16, color: text),
      displaySmall: GoogleFonts.inter(fontSize: 16, color: text),
      headlineLarge: GoogleFonts.inter(fontSize: 16, color: text),
      headlineMedium: GoogleFonts.inter(fontSize: 16, color: text),
      headlineSmall: GoogleFonts.inter(fontSize: 16, color: text),
      // target App Bars
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: text),
      titleMedium: GoogleFonts.inter(fontSize: 16, color: text),
      titleSmall: GoogleFonts.inter(fontSize: 16, color: text),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: text),
      bodyMedium: GoogleFonts.inter(fontSize: 16, color: text),
      bodySmall: GoogleFonts.inter(fontSize: 16, color: text),
      // targets Elevated Buttons
      labelLarge: GoogleFonts.inter(fontSize: 16, color: text, fontWeight: FontWeight.bold),
      labelMedium: GoogleFonts.inter(fontSize: 16, color: text),
      labelSmall: GoogleFonts.inter(fontSize: 16, color: text),
    ),

    appBarTheme: const AppBarTheme(
      color: background,
      centerTitle: true,
      iconTheme: IconThemeData(color: primary, size: 40),
    ),


    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: accent),
        borderRadius: BorderRadius.circular(20),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: attention),
        borderRadius: BorderRadius.circular(20),
      ),
      errorStyle: const TextStyle(
        color: text,
        fontSize: 14.0,
      ),     
      labelStyle: GoogleFonts.inter(fontSize: 14, color: text),
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.fromLTRB(45, 15, 45, 15),
      alignLabelWithHint: true, 
      floatingLabelAlignment: FloatingLabelAlignment.center,
      ),
    

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return secondary;
            } else if (states.contains(MaterialState.error)) {
              return attention;
            } else {
              return primary;
            }
          },
        ),
        elevation: MaterialStateProperty.resolveWith<double>(
        (Set<MaterialState> states) {
          return states.contains(MaterialState.disabled)
              ? 0
              : 5;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) => text,
        ),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
          (Set<MaterialState> states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          ),
        ),
        minimumSize: MaterialStateProperty.all<Size>(
        const Size(218, 56),
        ),
      ),

    // textButtonTheme: TextButtonThemeData(
    // style: TextButton.styleFrom(
      
    // ),
     
      //   padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
      //   const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      ),
    );

    // cardTheme: CardTheme(
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(4.0),
    //   ),
    //   color: accent,

