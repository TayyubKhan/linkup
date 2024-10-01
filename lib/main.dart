import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkup/temp/screens/bluetooth_off_screen.dart';
import 'package:linkup/temp/screens/scan_screen.dart';
import 'package:linkup/temporary/scan.dart';
import 'package:linkup/utils/routes/routesName.dart';
import 'package:linkup/utils/routes/routesSetting.dart';
import 'features/Continue/View/ContinueScreen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

ThemeData theme = ThemeData();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        scaffoldBackgroundColor:
            const Color(0xffF7F7F7), // Body background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff1a1a1a), // App bar background color
          elevation: 10, // App bar elevation
          iconTheme:
              IconThemeData(color: Color(0xffF7F7F7)), // App bar icon color
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
      home:  NearbyCommunicationScreen(),
      // onGenerateRoute: AppRoutesSetting.generateRoutes,
      // initialRoute: RoutesName.splashView,
      navigatorKey: navigatorKey,
    );
  }
}

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(
      color: Colors.lightBlue,
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

//
// This observer listens for Bluetooth Off and dismisses the DeviceScreen
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??=
          FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
