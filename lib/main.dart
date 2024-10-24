import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/temporary/temp.dart';
import 'package:linkup/utils/colors.dart';
import 'package:linkup/utils/routes/routesName.dart';
import 'package:linkup/utils/routes/routesSetting.dart';

import 'core/notificationRepo.dart';
import 'core/servcies_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init(); // Initialize notifications
  runApp(ProviderScope(child: MyApp()));
}

ThemeData theme = ThemeData();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    setupLocator(ref);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryBlack, // Primary color
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryWhite, // Seed color for ColorScheme
          primary: primaryBlack, // Primary color for components
          secondary: Colors.blue, // Secondary color
          background: primaryWhite, // Background color
          surface: Colors.grey, // Surface color (like Card, AppBar background)
        ),
        scaffoldBackgroundColor: primaryWhite, // Body background color
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlack, // App bar background color
          elevation: 10, // App bar elevation
          iconTheme: IconThemeData(color: primaryWhite), // App bar icon color
          titleTextStyle: TextStyle(
              color: primaryWhite, fontSize: 20), // App bar title style
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
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: primaryBlack, fontFamily: 'pop'), //
          bodySmall: TextStyle(
              color: primaryBlack, fontFamily: 'pop'), // Body text style
          bodyMedium: TextStyle(
              color: primaryBlack,
              fontFamily: 'pop'), // Secondary body text style
          titleLarge: TextStyle(
              color: primaryBlack,
              fontSize: 32,
              fontFamily: 'pop',
              fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(
              color: primaryBlack,
              fontSize: 22,
              fontFamily: 'pop',
              fontWeight: FontWeight.w900),
          labelSmall: TextStyle(
              color: primaryWhite,
              fontSize: 18,
              fontFamily: 'pop',
              fontWeight: FontWeight.w600), // App title text style
        ),
        /**/
        iconTheme: IconThemeData(
          color: primaryBlack,
        ),
        useMaterial3: true, // Opt-in for Material 3 design
      ),
      // home: const NearbyCommunicationScreen(),
      onGenerateRoute: AppRoutesSetting.generateRoutes,
      initialRoute: RoutesName.splashView,
      navigatorKey: navigatorKey,
    );
  }
}
