
import 'package:flutter/cupertino.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';


import '../views/views.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("route: ${settings.name}");


    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case Routes.play:
        return MaterialPageRoute(builder: (_) => const PlayPage());
      case Routes.padlock:
        return MaterialPageRoute(builder: (_) => const PadlockPage());
      case Routes.generateTicket:
        return MaterialPageRoute(builder: (_) => const GenerateTicket());
      case Routes.month:
        return MaterialPageRoute(builder: (_) => const MonthPage());
      case Routes.sellPadlock:
        return MaterialPageRoute(builder: (_) => const ResetMonthsPage());
      case Routes.moneyGenerated:
        return MaterialPageRoute(builder: (_) => const MoneyGeneratedInMonthPage());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case Routes.registerUser:
        return MaterialPageRoute(builder: (_) => const RegisterUserPage());
      case Routes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangeUserPasswordPage());
      case Routes.users:
        return MaterialPageRoute(builder: (_) => const UsersPage());
      case Routes.user:
        return MaterialPageRoute(builder: (_) => const UserPage());
      case Routes.plays:
        return MaterialPageRoute(builder: (_) => const PlaysPage());
      case Routes.collectors:
        return MaterialPageRoute(builder: (_) => const CollectorsPage());
      case Routes.collector:
        return MaterialPageRoute(builder: (_) => const CollectorPage());
      case Routes.disabledNumbers:
        return MaterialPageRoute(builder: (_) => const DisabledNumbersPage());
      case Routes.disabledBets:
        return MaterialPageRoute(builder: (_) => const DisabledBetsPage());
      case Routes.app:
        return MaterialPageRoute(builder: (_) => const AppPage());
      case Routes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case Routes.searchPlay:
        return MaterialPageRoute(builder: (_) => const SearchPlayPage());
      case Routes.help:
        return MaterialPageRoute(builder: (_) => const HelpPage());
      case Routes.enabledMonths:
        return MaterialPageRoute(builder: (_) => const EnabledMonthsPage());
      default:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

    }
  }
}
abstract class Routes{
  static const String login = '/login';
  static const String home = '/home';
  static const String welcome = '/welcome';
  static const String users = '/users';
  static const String user = '/user';
  static const String registerUser = '/registerUser';
  static const String changePassword = '/changePassword';
  static const String help = '/help';
  static const String plays = '/plays';
  static const String play = '/play';
  static const String searchPlay = '/searchPlay';
  static const String collectors = '/collectors';
  static const String collector = '/collector';
  static const String disabledNumbers = '/disabledNumbers';
  static const String disabledBets = '/disabledBets';
  static const String padlock = '/padlock';
  static const String generateTicket = '/generateTicket';
  static const String month = '/month';
  static const String sellPadlock = '/sellPadlock';
  static const String moneyGenerated = '/moneyGenerated';
  static const String app = '/app';
  static const String enabledMonths = '/enabledMonths';

}
