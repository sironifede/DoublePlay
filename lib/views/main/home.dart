
import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../shimmer.dart';

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
      _refresh();
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
                    child: Text("ACEPTAR"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }).then((value) {
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);

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
                actions: [
                  TextButton(
                    child: Text("ACEPTAR"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }).then((value) {
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);

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
                    "Nunca terminaste tu anterior jugada, puedes volver a donde te habias quedado o descartarla."),
                actions: [
                  TextButton(
                    child: Text("DESCARTAR"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    child: Text("SEGUIR JUGANDO"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              );
            }).then((value) {
              if (value != null){
                if (value){
                  mm.removePadlock(model: mm.padlock);
                }else{
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.play, (Route<dynamic> route) => false);
                }
              }else{
                mm.removePadlock(model: mm.padlock);
              }
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {

              Navigator.of(context).pushNamed(Routes.help);
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              mm.selectUser(mm.user);
              Navigator.of(context).pushNamed(Routes.user);
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
      body:RefreshIndicator(
        onRefresh: _refresh,
        child: Shimmer(
          child: ShimmerLoading(
            isLoading: (mm.status == ModelsStatus.updating),
            child: ListView(
              children: [
                Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children:generateColumn()
                ),
              ]
            ),
          ),
        ),
      )
    );
  }
  Future<void> _refresh() async {
    await mm.fetchUser();
    if (!mm.user.isStaff && !mm.user.isSuperuser) {
      await mm.updateUsers();
      await mm.updateCollectors();
      if (!mm.user.isCollector ) {
        mm.showContinuePlayingDialog = await mm.isUserPlaying();
        if (mm.showContinuePlayingDialog) {
          await mm.updatePlays(filter: PlayFilter(padlocks: [mm.padlock.id]));
        }
      }
    }


  }
  List<Widget> generateColumn(){
    List<Widget> list = [];
    if (!mm.user.isStaff && !mm.user.isSuperuser && !mm.user.isCollector) {
      list.add(
        OptionWidget(
          onPressed:(mm.status == ModelsStatus.updating)? null : () {
            Navigator.of(context).pushNamed(Routes.month);
          },
          text: "Jugar",
          backgroundImage: "assets/images/ruleta.png",
        ),
      );
      list.add(
          OptionWidget(
            onPressed: (mm.status == ModelsStatus.updating)? null : () {
              mm.selectUser(mm.user);
              Navigator.of(context).pushNamed(Routes.plays);
            },
            text: "Ver jugadas",
            backgroundImage: "assets/images/jugadas.jpg",
          )
      );
    }
    if (mm.user.isCollector){
      list.add(
        OptionWidget(
          onPressed: (mm.status == ModelsStatus.updating)? null : (){
            Navigator.of(context).pushNamed(Routes.collector);
          },
          text: "Ver dinero recaudado",
          backgroundImage: "assets/images/money.png",

        ),
      );
    }

    if (mm.user.isStaff) {
      list.add(
          OptionWidget(
            onPressed: (mm.status == ModelsStatus.updating)? null : (){
              Navigator.of(context).pushNamed(Routes.users);
            },
            text: "Administrar Usuarios",
            backgroundImage: "assets/images/users.png",
          ),
      );
      list.add(
        OptionWidget(
          onPressed: (mm.status == ModelsStatus.updating)? null : (){
            Navigator.of(context).pushNamed(Routes.collectors);
          },
          text: "Administrar colectores",
          backgroundImage: "assets/images/users.png",
        ),
      );
      list.add(
          OptionWidget(
            onPressed: (mm.status == ModelsStatus.updating)? null : (){
              Navigator.of(context).pushNamed(Routes.disabledNumbers);
            },
            text: "Agregar/Remover numeros",
            backgroundImage: "assets/images/numbers.jpg",
          )
      );
      list.add(
          OptionWidget(
            onPressed: (mm.status == ModelsStatus.updating)? null : (){
              Navigator.of(context).pushNamed(Routes.disabledBets);
            },
            text: "Agregar/Remover apuestas",
            backgroundImage: "assets/images/numbers.jpg",
          )
      );

      list.add(
          OptionWidget(
            onPressed: (mm.status == ModelsStatus.updating)? null : () {
              Navigator.of(context).pushNamed(Routes.app);
            },
            text: "Habilitar/Deshabilirtar app",
            backgroundImage: "assets/images/switch.webp",
          )
      );
      list.add(
          OptionWidget(
            onPressed: (mm.status == ModelsStatus.updating)? null : () {
              Navigator.of(context).pushNamed(Routes.searchPlay);
            },
            text: "Ingresar Jugada",
            backgroundImage: "assets/images/ruleta.png",
          )
      );
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

