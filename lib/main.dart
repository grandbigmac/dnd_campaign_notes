import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_build_experiment/views/core_view.dart';
import 'package:ui_build_experiment/views/create_view.dart';
import 'package:ui_build_experiment/views/main_view.dart';
import 'package:ui_build_experiment/views/navbar.dart';
import 'package:ui_build_experiment/views/profile_view.dart';
import 'package:ui_build_experiment/views/splash.dart';

import 'firebase_options.dart';

void main() async {
  //Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    log('Rebuilt all');

    return MaterialApp(
      title: 'UI Experiments',
      theme: ThemeData(
        primaryColor: Colors.grey.shade800,
        secondaryHeaderColor: Colors.grey.shade600,
        fontFamily: GoogleFonts.poppins().fontFamily,
        focusColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey.shade800,
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
        ),
        iconTheme: IconThemeData(
          color: Colors.grey.shade700,
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.grey.shade900,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.075, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.065, fontWeight: FontWeight.bold, color: Colors.white),
          titleSmall: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.055, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
          bodyMedium: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03),
          bodySmall: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.02),
          labelSmall: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.blue),
          labelMedium: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.white),
          labelLarge: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, color: Colors.white),
        )
      ),
      home: const Splash(),
    );
  }
}

