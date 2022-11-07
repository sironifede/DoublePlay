
import 'package:animations/animations.dart';
import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';
import '../views.dart';

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
    Future.delayed(Duration(milliseconds: 1),(){
      mm.updateUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(mm.status);
    mm = context.watch<ModelsManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              mm.updateUser();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed("/settings");
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
            leading: const Text(""),
            title: Text('Tu usuario',style: TextStyle(color: Theme.of(context).primaryColor),),
          )
      );
      list.add(
          OpenContainer(
            openBuilder: (_, closeContainer) => const UserPage(),
            tappable: false,
              closedColor: Theme.of(context).dialogBackgroundColor,
              openColor: Colors.transparent,
            closedBuilder: (_, openContainer) =>
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(mm.user!.username),
                  onTap: (){
                    mm.selectUser(mm.user!);
                    openContainer();
                  },
                )
          ),

      );
      list.add(Divider());
      list.add(
          ListTile(
            title: Text("Opciones:"),
          )
      );
      list.add(
          ElevatedButton(
              onPressed: null,
              child: SizedBox(
                  width:MediaQuery.of(context).size.width/3,
                  child: Center(child: Text("Jugar"))
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
      if (mm.user!.isStaff){
        list.add(
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pushNamed(Routes.users);
                },
                child: SizedBox(
                    width:MediaQuery.of(context).size.width/3,
                    child: Center(child: Text("Administrar Usuarios"))
                )
            )
        );
        list.add(
            ElevatedButton(
                onPressed: null,
                child: SizedBox(
                    width:MediaQuery.of(context).size.width/3,
                    child: Center(child: Text("Agregar/Remover numeros"))
                )
            )
        );
        list.add(
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pushNamed(Routes.app);
                },
                child: SizedBox(
                    width:MediaQuery.of(context).size.width/3,
                    child: Center(child: Text("Habilitar/Deshabilirtar app"))
                )
            )
        );
      }
    }

    return list;
  }
}
