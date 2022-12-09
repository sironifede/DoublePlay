// ignore: unused_import
// ignore_for_file: unnecessary_import, unused_import, depend_on_referenced_packages, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, body_might_complete_normally_nullable

import 'package:bolita_cubana/models/models.dart';
import 'package:bolita_cubana/models/models_manager.dart' as g;
import 'package:bolita_cubana/routes/route_generator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:provider/provider.dart';

import '../../models/models_manager.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String _errorUsername = "";
  String _errorPassword = "";

  bool loading = false;
  late ModelsManager mm;



  bool obscure = true;

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
  }

  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    if (mm.user.userStatus == UserStatus.appNotActive){
      mm.user.userStatus = UserStatus.unauthenticated;
      Future.delayed(Duration(milliseconds: 1),(){
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                icon: const Icon(Icons.warning),
                title: Text("La aplicacion no esta habilitada, se podra usar cuando un administrador la habilite."),
                actions: [
                  TextButton(
                    child: Text("ACEPTAR"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });
      });
    }
    loading = false;
    if(mm.status == ModelsStatus.updating){
      loading = true;

    }

    // Constructor de la ventana Login
    return Scaffold(
      appBar: AppBar(
        title: Text("Double Play - Inicio de sesion"),
      ),
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
            children: [
              SingleChildScrollView(
                // Al colocarla dentro se evita problemas con la vista en caso de que se gire la pantalla
                child: SizedBox(
                  height: MediaQuery.of(context).size.height-92,
                  child: Column(
                    children: [
                      Expanded(child: Text("")),
                      Card(
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                    enabled: !loading,
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
                                      labelText: "Usuario",
                                      hintText: "Nombre de usuario",
                                      icon: Icon(Icons.person),
                                    )
                                ),

                                TextFormField(
                                    enabled: !loading,
                                    validator:(val){
                                      if(val == null || val == "" ) {
                                        return  "Campo obligatorio";
                                      }
                                      if (_errorPassword != ''){
                                        return _errorPassword;
                                      }
                                    },
                                    controller: passwordController,
                                    obscureText: obscure,
                                    decoration: InputDecoration(
                                        labelText: "Contraseña",
                                        hintText: "Contraseña del usuario",
                                        icon: Icon(Icons.vpn_key_sharp),
                                        suffixIcon:  IconButton(
                                          icon: Icon((obscure)?Icons.remove_red_eye_outlined: Icons.remove_red_eye),
                                          onPressed: (){
                                            setState(() {
                                              obscure = !obscure;
                                            });
                                          },
                                        )
                                    )
                                ),

                                Container(height:16),
                                ElevatedButton.icon(
                                  icon: (loading)? CircularProgressIndicator(): Container(),
                                  autofocus: true,
                                  onPressed: (!loading)?() async {
                                    setState(() {
                                      _errorUsername = "";
                                      _errorPassword = "";
                                    });
                                    if (_formKey.currentState!.validate())   {
                                      mm.authenticateUser(username: usernameController.text,
                                          password: passwordController.text)
                                          .then((value) async  {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);
                                      }, onError: (error) {
                                        if (mm.user.userStatus != UserStatus.appNotActive) {
                                          setState(() {
                                            print(error);
                                            _errorUsername =
                                            (error['non_field_errors'].toString() ==
                                                "null")
                                                ? ""
                                                : error['non_field_errors'][0].toString();
                                            _errorPassword =
                                            (error['non_field_errors'].toString() ==
                                                "null")
                                                ? ""
                                                : error['non_field_errors'][0].toString();
                                            _formKey.currentState!.validate();
                                          });
                                        }


                                      });
                                    }
                                  }:null,
                                  label: Text("Iniciar Sesion"),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Text("")),
                    ],
                  ),
                ),
              ),

            ]
        ),
      )
    );
  }
}
