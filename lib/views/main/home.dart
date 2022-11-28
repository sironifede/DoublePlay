
import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key,}): super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool left = false;
  late ModelsManager mm;

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      await mm.fetchUser();
      mm.showContinuePlayingDialog = await  mm.isUserPlaying();
      if (mm.showContinuePlayingDialog){
        mm.updatePlays(filter: PlayFilter(padlock: mm.padlock.id.toString()));
      }
      mm.updateDisabledNumbers();
      mm.updateDisabledBets();
      if (mm.user.isStaff || mm.user.isSuperuser){
        mm.updateCollectors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    if (mm.user.userStatus == UserStatus.unauthorized){
      mm.user.userStatus = UserStatus.unauthenticated;
      Future.delayed(Duration(milliseconds:1), (){
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                icon: const Icon(Icons.warning),
                title: Text("Tu usuario ha sido deshabilitado o eliminado no puedes acceder a la app hasta que se te permita por un admin."),
                actions: [
                  TextButton(
                    child: Text("CERRAR SESION"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    child: Text("ACEPTAR"),
                    onPressed: () {
                      SystemNavigator.pop();

                    },
                  ),
                ],
              );
            }).then((value){
          if (value != null){
            if (value){
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
            }
          }else{
            SystemNavigator.pop();
          }
        });
      });
    }else if (mm.user.userStatus == UserStatus.appNotActive) {
      mm.user.userStatus = UserStatus.unauthenticated;
      Future.delayed(Duration(milliseconds: 1), () {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                icon: const Icon(Icons.warning),
                title: Text(
                    "La aplicacion no esta habilitada, se podra usar cuando un administrador la habilite."),
                content: Text(
                    "La aplicacion se cerro a las: ${mm.app.stopHour.format(
                        context)}"),
                actions: [
                  TextButton(
                    child: Text("CERRAR SESION"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    child: Text("ACEPTAR"),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              );
            }).then((value) {
          if (value != null){
            if (value){
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
            }
          }else{
            SystemNavigator.pop();
          }
        });
      });
    }else if (mm.showContinuePlayingDialog){
      mm.showContinuePlayingDialog = false;
      Future.delayed(Duration(milliseconds: 1), () {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                icon: const Icon(Icons.warning),
                title: Text("Ya estabas jugando"),
                content: Text(
                    "Nunca terminaste tu anterior jugada, ahora puedes volver a donde te habias quedado"),
                actions: [
                  TextButton(
                    child: Text("CERRAR SESION"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    child: Text("ACEPTAR"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              );
            }).then((value) {
              if (value != null){
                if (value){
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
                }else{
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.play, (Route<dynamic> route) => false);
                }
              }else{
                Navigator.of(context).pushNamedAndRemoveUntil(Routes.play, (Route<dynamic> route) => false);
              }
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              mm.selectUser(mm.user);
              Navigator.of(context).pushNamed(Routes.user);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await mm.fetchUser();
              mm.showContinuePlayingDialog = await mm.isUserPlaying();
              if (mm.showContinuePlayingDialog){
                mm.updatePlays(filter: PlayFilter(padlock: mm.padlock.id.toString()));
              }
              mm.updateDisabledNumbers();
              mm.updateDisabledBets();
              if (mm.user.isStaff || mm.user.isSuperuser){
                mm.updateCollectors();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          mm.user = User();
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
        },
        label: Text("CERRAR SESION"),
      ),
      body:SingleChildScrollView(
        child: Wrap(
            alignment: WrapAlignment.spaceBetween,
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
          OptionWidget(
            onPressed: (){
              Navigator.of(context).pushNamed(Routes.month);
            },
            text: "Jugar",
            backgroundImage: "assets/images/ruleta.png",
          ),
      );
      list.add(
          OptionWidget(
            onPressed: (){
              mm.selectUser(mm.user);
              Navigator.of(context).pushNamed(Routes.plays);
            },
            text: "Ver jugadas",
            backgroundImage: "assets/images/jugadas.jpg",
          )
      );

      if (mm.user != null) {
        if (mm.user.isStaff) {
          list.add(
              OptionWidget(
                onPressed: (){
                  Navigator.of(context).pushNamed(Routes.users);
                },
                text: "Administrar Usuarios",
                backgroundImage: "assets/images/users.png",
              ),
          );
          list.add(
            OptionWidget(
              onPressed: (){
                Navigator.of(context).pushNamed(Routes.collectors);
              },
              text: "Administrar colectores",
              backgroundImage: "assets/images/users.png",
            ),
          );
          list.add(
              OptionWidget(
                onPressed: (){
                  Navigator.of(context).pushNamed(Routes.disabledNumbers);
                },
                text: "Agregar/Remover numeros",
                backgroundImage: "assets/images/numbers.jpg",
              )
          );
          list.add(
              OptionWidget(
                onPressed: (){
                  Navigator.of(context).pushNamed(Routes.disabledBets);
                },
                text: "Agregar/Remover apuestas",
                backgroundImage: "assets/images/numbers.jpg",
              )
          );
          list.add(
              OptionWidget(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.app);
                },
                text: "Habilitar/Deshabilirtar app",
                backgroundImage: "assets/images/switch.webp",
              )
          );
        }
      }
    }

    return list;
  }
}
class OptionWidget extends StatelessWidget {
  const OptionWidget({required this.onPressed, required this.backgroundImage,required this.text});
  final String text;
  final String backgroundImage;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width / 2 ,
      height: MediaQuery.of(context).size.width / 2 ,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
            child: Container(
                child: Center(
                    child: Text(text, style: TextStyle(fontSize: 30),)
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      opacity: 0.3,
                        image:AssetImage(backgroundImage),
                        fit:BoxFit.cover
                    ),
                    // button text
                )
            ),
            onTap:onPressed
        ),
      ),
    );
  }
}

