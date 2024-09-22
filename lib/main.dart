import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/utils/routes/routesName.dart';
import 'package:linkup/utils/routes/routesSetting.dart';
import 'features/Continue/View/ContinueScreen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

ThemeData theme = ThemeData();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xff1a1a1a), // Primary color
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffF7F7F7), // Seed color for ColorScheme
          primary: const Color(0xff1a1a1a), // Primary color for components
          secondary: Colors.blue, // Secondary color
          background: const Color(0xffF7F7F7), // Background color
          surface: Colors.grey, // Surface color (like Card, AppBar background)
        ),
        scaffoldBackgroundColor: const Color(0xffF7F7F7), // Body background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff1a1a1a), // App bar background color
          elevation: 10, // App bar elevation
          iconTheme: IconThemeData(color: Color(0xffF7F7F7)), // App bar icon color
          titleTextStyle: TextStyle(
              color: Color(0xffF7F7F7), fontSize: 20), // App bar title style
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
          bodyLarge: TextStyle(color: Color(0xff1a1a1a), fontFamily: 'pop'), //
          bodySmall: TextStyle(
              color: Color(0xff1a1a1a), fontFamily: 'pop'), // Body text style
          bodyMedium: TextStyle(
              color: Color(0xff1a1a1a),
              fontFamily: 'pop'), // Secondary body text style
          titleLarge: TextStyle(
              color: Color(0xff1a1a1a),
              fontSize: 32,
              fontFamily: 'pop',
              fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(
              color: Color(0xff1a1a1a),
              fontSize: 22,
              fontFamily: 'pop',
              fontWeight: FontWeight.w900),
          labelSmall: TextStyle(
              color: Color(0xffF7F7F7),
              fontSize: 18,
              fontFamily: 'pop',
              fontWeight: FontWeight.w600), // App title text style
        ),
        /**/
        iconTheme: const IconThemeData(
          color: Color(0xff1a1a1a),
        ),
        useMaterial3: true, // Opt-in for Material 3 design
      ),
      onGenerateRoute: AppRoutesSetting.generateRoutes,
      initialRoute: RoutesName.welcomeView,
    );
  }
}
