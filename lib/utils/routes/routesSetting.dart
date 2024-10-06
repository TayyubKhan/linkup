import 'package:flutter/material.dart';
import 'package:linkup/features/continue/view/ContinueScreen.dart';
import 'package:linkup/features/home/view/home_view.dart';
import 'package:linkup/features/searchscreen/view/search_view.dart';
import 'package:linkup/features/setting/view/setting_view.dart';
import 'package:linkup/features/splash/view/splash_view.dart';
import 'package:linkup/features/welcomeview/view/welcome_view.dart';
import 'package:linkup/utils/routes/routesName.dart';

import '../../features/password/view/password_view.dart';

class AppRoutesSetting {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homeView:
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeView());
      case RoutesName.continueView:
        return MaterialPageRoute(
            builder: (BuildContext context) => ContinueView());
      case RoutesName.settingView:
        return MaterialPageRoute(
            builder: (BuildContext context) => SettingsView());
      case RoutesName.splashView:
        return MaterialPageRoute(
            builder: (BuildContext context) => SplashView());
      case RoutesName.welcomeView:
        return MaterialPageRoute(
            builder: (BuildContext context) => WelcomeView());
      case RoutesName.passwordView:
        return MaterialPageRoute(
            builder: (BuildContext context) => PasswordView());
      case RoutesName.searchView:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SearchView());
      // case RoutesName.advertiseView:
      //   return MaterialPageRoute(
      //       builder: (BuildContext context) => AdvertiseView());
      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(
              child: Text('You are on the Wrong way'),
            ),
          );
        });
    }
  }
}
