
import 'package:flutter/material.dart';
import 'package:theme_mode_handler/theme_mode_manager_interface.dart';

CustomTheme currentTheme = CustomTheme();

class CustomTheme extends ChangeNotifier{
  static ThemeData get lightTheme {
    return ThemeData.light(

    );
  }
  static ThemeData get darkTheme {
    return ThemeData.dark(
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
