import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String _errorUsername = "";
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {

      usernameController..text = mm.selectedUser!.username;
    });
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Usuario"),
        ),
        body:ListView(
          children: generateColumn(),
        )
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];

    list.add(
        ListTile(
          title: Text('Usuario: ${mm.selectedUser?.username}'),
          subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tipo de usuario: ${(mm.selectedUser!.isSuperuser)
                    ? "Superusuario"
                    : (mm.selectedUser!.isStaff) ? "Admin" : (mm.selectedUser!
                    .isCollector) ? "Colector" : "Listero"}"),
                Text("Cuenta creada el: ${(mm.selectedUser!.dateJoined == null)
                    ? "No se sabe"
                    : DateFormat('yyyy-MMMM-dd HH:mm a').format(
                    mm.selectedUser!.dateJoined!.toLocal())}"),
                Text("Ultimo inicio de sesion: ${(mm.selectedUser!.lastLogin ==
                    null) ? "No se sabe" : DateFormat('yyyy-MMMM-dd HH:mm a')
                    .format(mm.selectedUser!.lastLogin!.toLocal())}"),
              ]
          ),
        )
    );
    if (mm.user.isSuperuser || (mm.user.isStaff && !mm.selectedUser!.isStaff && !mm.selectedUser!.isSuperuser)) {
      list.add(
          CheckboxListTile(
              title: Text('Usuario activo: '),
              subtitle: Text(
                  "Asi puedes negarle el acceso para que no pueda entrar a la app"),

              onChanged: (e) {
                mm.selectedUser!.isActive = !mm.selectedUser!.isActive;
                mm.updateModel(modelType: ModelType.user,model: mm.selectedUser!);
              },
              value: mm.selectedUser!.isActive
          )
      );
    }
    if (mm.user.isSuperuser || (mm.user.isStaff && !mm.selectedUser!.isStaff && !mm.selectedUser!.isSuperuser) || (mm.user.id == mm.selectedUser!.id && (mm.user.isSuperuser || mm.user.isStaff))) {
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: TextFormField(
                enabled: !(mm.status == ModelsStatus.updating),
                validator:(val){
                  if(val == null || val == "" ) {
                    return "Campo obligatorio";
                  }
                  if (_errorUsername != ''){
                    return _errorUsername;
                  }
                },
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Nombre de usuario",
                  hintText: "Nombre de usuario",
                  icon: Icon(Icons.person),
                )
            ),
          ),
        ),
      );
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text("")
              ),
              ElevatedButton.icon(
                  icon: (mm.status == ModelsStatus.updating)? CircularProgressIndicator(): Container(),
                  onPressed: (mm.status == ModelsStatus.updating)? null : (){
                    setState(() {
                      _errorUsername = "";
                    });
                    if (_formKey.currentState!.validate()) {
                      String username = mm.selectedUser!.username;
                      mm.selectedUser!.username = usernameController.text;
                      mm.changeUsername(model: mm.selectedUser!).then((value) {
                        mm.selectedUser = User.fromMap(value);
                      }, onError: (error) {
                        mm.status = ModelsStatus.updated;
                        mm.selectedUser!.username = username;
                        setState(() {
                          print(error);
                          _errorUsername = (error['username'].toString() == "null") ? "" : error['username'][0].toString();
                          _formKey.currentState!.validate();
                        });
                      });
                    }
                  },
                  label: Text("CAMBIAR")
              )
            ],
          ),
        ),
      );

    }



    list.add(Divider());
    list.add(
        ListTile(
          title: Text("Opciones:"),
        )
    );
    List<Widget> children = [];
    if (!mm.selectedUser!.isStaff && !mm.selectedUser!.isSuperuser && !mm.selectedUser!.isCollector) {
      children.add(
          ElevatedButton(
              onPressed: () {
                mm.updateModel(modelType: ModelType.user,model: mm.selectedUser!);
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
    if (mm.user.isSuperuser || (mm.user.isStaff && !mm.selectedUser!.isSuperuser && !mm.selectedUser!.isStaff) || (mm.selectedUser!.id == mm.user.id)){
      children.add(
          ElevatedButton(
              onPressed: (){
                Navigator.of(context).pushNamed(Routes.changePassword);
              },
              child: SizedBox(
                  width:MediaQuery.of(context).size.width/3,
                  child: Center(child: Text("Cambiar contraseña"))
              )
          )
      );
    }

    if (mm.selectedUser!.id == mm.user.id) {
      print("si es el mismmoooooooooooooooo");
      children.add(
          ElevatedButton(
              onPressed: () async {
                mm.user = User();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.welcome, (Route<dynamic> route) => false);
              },
              child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 3,
                  child: Center(child: Text("Cerrar sesion"))
              )
          )
      );
    }
    if (mm.selectedUser!.id != mm.user.id) {
      if (mm.user.isSuperuser || (mm.user.isStaff && !(mm.selectedUser!.isSuperuser || mm.selectedUser!.isStaff))) {
        children.add(
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
                      await mm.removeModel(modelType: ModelType.user,
                          model: mm.selectedUser!);
                      Navigator.of(context).pop();
                      mm.updateModels(modelType: ModelType.user,filter: UserFilter(isStaff: false, isSuperUser: false));
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
    list.add(
        Row(
          children: [
            Expanded(child: Text("")),
            Column(
              children: children
            ),
            Expanded(child: Text("")),
          ],
        )
    );


    return list;
  }
}

