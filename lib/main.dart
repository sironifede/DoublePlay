import 'package:bolita_cubana/repository/user_repository.dart';
import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/themes/themes.dart';
import 'package:bolita_cubana/views/views.dart';
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
  UserRepository userRepository = UserRepository();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ThemeModeHandler(
        manager: MyManager(),
        placeholderWidget: Center(
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
            home: FutureBuilder<bool>(
                future: userRepository.hasToken(id: 0),
                builder: (context,snapshot) {

                  if (snapshot.hasData){
                    if (snapshot.data!){
                      return HomePage();
                    }else{
                      return WelcomePage();
                    }
                  }
                  return CircularProgressIndicator();
                }
            ),
          );
        }
    );
  }
}

