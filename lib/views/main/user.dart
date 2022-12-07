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


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {

    });
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Usuario"),
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
            title: Text('Usuario: ${mm.selectedUser.username}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text("Tipo de usuario: ${(mm.selectedUser.isSuperuser)? "Superusuario": (mm.selectedUser.isStaff)?"Admin":(mm.selectedUser.isCollector)?"Colector":  "Listero"}"),
                Text("Cuenta creada el: ${(mm.selectedUser.dateJoined== null)?"No se sabe": mm.selectedUser.dateJoined!.toLocal().toString().split(".")[0]}"),
                Text("Ultimo inicio de sesion: ${(mm.selectedUser.lastLogin== null)?"No se sabe": mm.selectedUser.lastLogin!.toLocal().toString().split(".")[0]}"),
              ]
            ),
          )
      );
      if (mm.user.isSuperuser || (mm.user.isStaff && !mm.user.isSuperuser && !mm.selectedUser.isStaff && !mm.selectedUser.isSuperuser)){
        list.add(
            CheckboxListTile(
                title: Text('Usuario activo: '),
                subtitle: Text(
                    "Asi puedes negarle el acceso para que no pueda entrar a la app"),

                onChanged: (e) {
                  mm.selectedUser.isActive = !mm.selectedUser.isActive;
                  mm.updateUser(model: mm.selectedUser);
                },
                value: mm.selectedUser.isActive
            )
        );
      }


      list.add(Divider());
      list.add(
          ListTile(
            title: Text("Opciones:"),
          )
      );
      if (!mm.selectedUser.isStaff && !mm.selectedUser.isSuperuser && !mm.selectedUser.isCollector) {
        list.add(
            ElevatedButton(
                onPressed: () {
                  mm.selectUser(mm.selectedUser);
                  Navigator.of(context).pushNamed(Routes.plays);
                },
                child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width / 3,
                    child: Center(child: Text("Ver jugadas"))
                )
            )
        );
      }
      /*if (mm.user.isSuperuser || (mm.user.isStaff && !mm.selectedUser.isSuperuser && !mm.selectedUser.isStaff) || (user == mm.user)){
        list.add(
            ElevatedButton(
                onPressed: null,
                child: SizedBox(
                    width:MediaQuery.of(context).size.width/3,
                    child: Center(child: Text("Cambiar contraseña"))
                )
            )
        );
      }*/

      if (mm.selectedUser == mm.user){
        print("si es el mismmoooooooooooooooo");
        list.add(
            ElevatedButton(
                onPressed: () async {
                  mm.user = User();
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
                },
                child: SizedBox(
                    width:MediaQuery.of(context).size.width/3,
                    child: Center(child: Text("Cerrar sesion"))
                )
            )
        );
      }
      if (!((!mm.user.isSuperuser && (mm.selectedUser.isSuperuser || mm.selectedUser.isStaff))&& mm.selectedUser != mm.user)) {
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
                      bool sameUser = await mm.removeUser(model: mm.selectedUser);
                      if (sameUser) {
                        mm.user = User();
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

