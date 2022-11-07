
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../views/views.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("route: ${settings.name}");


    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case Routes.registerUser:
        return MaterialPageRoute(builder: (_) => RegisterUserPage());
      case Routes.users:
        return MaterialPageRoute(builder: (_) => UsersPage());
      case Routes.plays:
        return MaterialPageRoute(builder: (_) => PlaysPage());
      case Routes.app:
        return MaterialPageRoute(builder: (_) => AppPage());
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => SettingsPage());
      default:
        return MaterialPageRoute(builder: (_) => WelcomePage());

    }
  }
}
abstract class Routes{
  static const String login = '/login';
  static const String home = '/home';
  static const String welcome = '/welcome';
  static const String users = '/users';
  static const String registerUser = '/registeruser';
  static const String settings = '/settings';
  static const String plays = '/plays';
  static const String app = '/app';
}
