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
    loading = false;
    if(mm.status == ModelsStatus.updating){
      loading = true;

    }

    // Constructor de la ventana Login
    return Scaffold(
      appBar: AppBar(
        title: Text("Double PLay - Inicio de sesion"),
      ),
      body:SingleChildScrollView(
        // Al colocarla dentro se evita problemas con la vista en caso de que se gire la pantalla
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
                    )
                ),
                CheckboxListTile(
                  title: Text("Mostrar contraseña"),
                  onChanged: (b){
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                  value: !obscure,

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
                      if (_formKey.currentState!.validate()) {
                        mm.authenticateUser(username: usernameController.text,
                            password: passwordController.text)
                            .then((value) {
                          g.userRepository.persistToken(user: value);
                          mm.status = ModelsStatus.updated;

                          Navigator.of(context)
                              .pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);

                        }, onError: (error) {
                          setState(() {
                            print(error);
                            _errorUsername = (error['non_field_errors'].toString() == "null")? "": error['non_field_errors'][0].toString();
                            _errorPassword = (error['non_field_errors'].toString() == "null")? "": error['non_field_errors'][0].toString();
                            _formKey.currentState!.validate();
                          });
                        });
                      }
                    }:null,
                    label: Text("Iniciar Sesion"),
                ),

              ],
            ),
          ),
        ),
      )
    );
  }
}
