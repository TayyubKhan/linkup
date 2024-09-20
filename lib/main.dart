import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'View/ContinueScreen/ContinueScreen.dart';
import 'View/HomeView.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black, // Primary color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black, // Seed color for ColorScheme
          primary: Colors.black, // Primary color for components
          secondary: Colors.green, // Secondary color
          background: Colors.white, // Background color
          surface: Colors.grey, // Surface color (like Card, AppBar background)
        ),
        scaffoldBackgroundColor: Colors.white, // Body background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // App bar background color
          elevation: 10, // App bar elevation
          iconTheme: IconThemeData(color: Colors.white), // App bar icon color
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20), // App bar title style
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8), // Rounded corners for TextField
            borderSide: BorderSide.none, // No border by default
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none
// Border color when focused
              ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          hintStyle: TextStyle(
              color: Colors.grey[600], fontFamily: 'pop'), // Hint text style
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontFamily: 'pop'), //
          bodySmall: TextStyle(
              color: Colors.black, fontFamily: 'pop'), // Body text style
          bodyMedium: TextStyle(
              color: Colors.black54,
              fontFamily: 'pop'), // Secondary body text style
          titleLarge: TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontFamily: 'pop',
              fontWeight: FontWeight.w700),
          labelSmall: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'pop',
              fontWeight: FontWeight.w600), // App title text style
        ),

        useMaterial3: true, // Opt-in for Material 3 design
      ),
      home: const ContinueScreen(),
    );
  }
}
