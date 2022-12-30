

import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';

class CustomScaffold extends StatefulWidget {
  const CustomScaffold({Key? key, this.appBar, this.body, this.floatingActionButton}) : super(key: key);
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  late ModelsManager mm;
  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
  }
  @override
  Widget build(BuildContext context) {
    mm = context.read<ModelsManager>();
    return Scaffold(
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      body: widget.body,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_outlined),
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                title: Text("Bienvenido a DoublePlay"),
                subtitle: Text("Hola de nuevo ${mm.user.username}!")
              ),
            ),
            ListTile(
              title:  Text('Usuario'),
              trailing: Icon(Icons.person),
              onTap: () {
                Navigator.of(context).pop();
                mm.selectedUser = mm.user;
                Navigator.of(context).pushNamed(Routes.user);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Ayuda'),
              trailing: Icon(Icons.help),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.help);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Inicio'),
              trailing: Icon(Icons.house),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);
              },
            ),
            Divider(),
            ListTile(
              title: Text('CERRAR SESION'),
              trailing: Icon(Icons.logout),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
