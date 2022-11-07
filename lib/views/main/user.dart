import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key,}): super(key: key);
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool left = false;
  late ModelsManager mm;
  User user = User();

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      user = mm.selectedUser!;
    });
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Usuario"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.settings);
              },
            ),
          ],
        ),
        body:SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children:generateColumn()
          ),
        )
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];
    if (mm.status == ModelsStatus.updating ){
      list.add(LinearProgressIndicator());
    }else {
      list.add(
          ListTile(
            title: Text('Usuario: ${user.username}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text("Tipo de usuario: ${(user.isSuperuser)? "Superusuario": (user.isStaff)?"Admin": "Listero"}"),
                Text("Cuenta creada el: ${(user.dateJoined== null)?"No se sabe": user.dateJoined!.toLocal().toString().split(".")[0]}"),
                Text("Ultimo inicio de sesion: ${(user.lastLogin== null)?"No se sabe": user.lastLogin!.toLocal().toString().split(".")[0]}"),
              ]
            ),
          )
      );


      list.add(Divider());
      list.add(
          ListTile(
            title: Text("Opciones:"),
          )
      );
      list.add(
          ElevatedButton(
              onPressed: (){
                mm.selectUser(user);
                Navigator.of(context).pushNamed(Routes.plays);
              },
              child: SizedBox(
                  width:MediaQuery.of(context).size.width/3,
                  child: Center(child: Text("Ver jugadas"))
              )
          )
      );
      list.add(
          ElevatedButton(
              onPressed: null,
              child: SizedBox(
                  width:MediaQuery.of(context).size.width/3,
                  child: Center(child: Text("Revisar"))
              )
          )
      );
      if (mm.user!.isSuperuser || (mm.user!.isStaff && !user.isSuperuser && !user.isStaff) || (user == mm.user)){
        list.add(
            ElevatedButton(
                onPressed: null,
                child: SizedBox(
                    width:MediaQuery.of(context).size.width/3,
                    child: Center(child: Text("Cambiar contraseña"))
                )
            )
        );
      }
      if (user == mm.user){
        list.add(
            ElevatedButton(
                onPressed: () async {
                  await mm.userRepository.deleteToken(id: 0);
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
                },
                child: SizedBox(
                    width:MediaQuery.of(context).size.width/3,
                    child: Center(child: Text("Cerrar sesion"))
                )
            )
        );
      }
      if (!((!mm.user!.isSuperuser && (user.isSuperuser || user.isStaff))&& user != mm.user!)) {
        list.add(
            ElevatedButton(
                onPressed: () async {
                  bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(
                              "Estas seguro de que quieres elimiar este usuario?"),
                          actions: [
                            TextButton(
                              child: Text("CANCELAR"),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text("ACEPTAR"),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      });
                  if (confirmDelete != null) {
                    if (confirmDelete) {
                      bool sameUser = await mm.removeUser(userToDelete: user);
                      if (sameUser) {
                        await mm.userRepository.deleteToken(id: 0);
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.welcome, (Route<dynamic> route) => false);
                      }
                      Navigator.of(context).pop();
                      mm.updateUsers(filter: UserFilter(
                          isStaff: false, isSuperUser: false));
                    }
                  }
                },
                child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width / 3,
                    child: Center(child: Text("Eliminar usuario"))
                )
            )
        );
      }
    }
    return list;
  }
}

