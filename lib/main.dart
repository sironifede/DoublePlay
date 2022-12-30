import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/themes/themes.dart';
import 'package:bolita_cubana/views/views.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';
import 'models/models_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ModelsManager()),

        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ThemeModeHandler(
        manager: MyManager(),
        placeholderWidget: const Center(
            child: CircularProgressIndicator()
        ),
        builder: (ThemeMode themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Double Play',
            theme: CustomTheme.lightTheme,
            highContrastTheme: CustomTheme.lightTheme,
            darkTheme: CustomTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: "/",
            onGenerateRoute: RouteGenerator.generateRoute,
            home: const WelcomePage(),
          );
        }
    );
  }
}

