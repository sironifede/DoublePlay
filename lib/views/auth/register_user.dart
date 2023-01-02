// ignore_for_file: depend_on_referenced_packages, body_might_complete_normally_nullable

import 'package:bolita_cubana/models/collector.dart';
import 'package:bolita_cubana/models/model.dart';
import 'package:bolita_cubana/models/user.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({Key? key}) : super(key: key);

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  String _errorUsername = "";
  String _errorPassword = "";
  String _errorPassword2 = "";
  List<String> userTypes = <String>['Listero'];
  String userType = 'Listero';

  bool loading = false;
  late ModelsManager mm;

  bool obscure = true;

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      if (mm.user.isSuperuser) {
        setState(() {
          userTypes.add('Superusuario');
          userTypes.add('Admin');
        });
      }
      if (mm.user.isStaff || mm.user.isSuperuser) {
        setState(() {
          userTypes.add('Colector');
        });
      }

    });

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
          title: Text("Añadir usuario"),
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
                  ListTile(
                    title: Row(
                      children: [
                        Text("Tipo de usuario:"),
                        Expanded(child:Text("") ),
                        DropdownButton<String>(
                          value: userType,
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              userType = value!;
                            });
                          },
                          items: userTypes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
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
                  TextFormField(
                      enabled: !loading,
                      validator:(val){
                        if(val == null || val == "" ) {
                          return  "Campo obligatorio";
                        }
                        if (_errorPassword2 != ''){
                          return _errorPassword2;
                        }
                      },
                      controller: password2Controller,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: "Confirmar contraseña",
                        hintText: "",
                        icon: Icon(Icons.vpn_key_sharp),
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
                        _errorPassword2 = "";
                      });
                      if (_formKey.currentState!.validate()) {
                        bool isStaff = false;
                        bool isSuperuser = false;
                        if (userType == "Admin") {
                          isStaff = true;
                        } else if (userType == "Superusuario") {
                          isStaff = true;
                          isSuperuser = true;
                        }

                        mm.registerUser(username: usernameController.text, isSuperuser: isSuperuser, isStaff: isStaff, password: passwordController.text, password2: password2Controller.text)
                            .then((value) async {
                              mm.status = ModelsStatus.updated;
                          if (userType == "Colector") {
                            print(value);
                            User user = User.fromMap(value);

                            await mm.createModel(modelType: ModelType.collector,model: Collector(id: 0, listers: [], user: user.id));
                          }

                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  icon: const Icon(Icons.check),
                                  title: Text("El usuario '${usernameController.text}' ha sido creado."),
                                  actions: [
                                    TextButton(
                                      child: Text("CERRAR"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
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
                          //Navigator.of(context).pushNamed(Routes., (Route<dynamic> route) => false);
                        }, onError: (error) {
                          mm.status = ModelsStatus.updated;
                          setState(() {
                            print(error);
                            _errorUsername = (error['username'].toString() == "null")? "": error['username'][0].toString();
                            _errorPassword = (error['password'].toString() == "null")? "": error['password'][0].toString();
                            _errorPassword2 = (error['password2'].toString() == "null")? "": error['password2'][0].toString();
                            _formKey.currentState!.validate();

                          });
                        });
                      }
                    }:null,
                    label: Text("Añadir usuario"),
                  ),

                ],
              ),
            ),
          ),
        )
    );
  }
}
