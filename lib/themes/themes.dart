
import 'package:flutter/material.dart';
import 'package:theme_mode_handler/theme_mode_manager_interface.dart';

CustomTheme currentTheme = CustomTheme();

class CustomTheme extends ChangeNotifier{
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFFC65F00),
      colorScheme: ColorScheme.fromSwatch().copyWith(
          brightness: Brightness.light,
          primary: Color(0xFFC65F00),
          secondary:Color(0xFF67BC00),
          surface: Colors.white
      ),
    );
  }
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFFC65F00),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: Brightness.dark,
        primary: Color(0xFFC65F00),
        secondary: Color(0xFF67BC00),
        surface:  Color(0xFF2B2B2B),
        onSurface: Color(0xFFFFFFFF),
      ),
    );
  }
}
class MyManager implements IThemeModeManager {
  @override
  Future<String> loadThemeMode() async {
    String theme = "ThemeMode.system";
    return theme;
  }

  @override
  Future<bool> saveThemeMode(String value) async {
    bool result = false;

    return result;
  }
}
