import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';

class AppPage extends StatefulWidget {
  const AppPage({Key? key,}): super(key: key);
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  bool left = false;
  late ModelsManager mm;

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),(){
      mm.getApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Estado de la app"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                mm.getApp();
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

            title: Text('Habilitada: ${(mm.app.active)? "Si": "No"}'),
            subtitle: Text('Hora de cierre: ${mm.app.stopHour.format(context).toString()}'),
          )
      );
      list.add(Divider());
      list.add(
        CheckboxListTile(
          title: Text("Aplicacion habilitada"),
          onChanged: (b){
            mm.app.active = !mm.app.active;
            mm.updateApp();
          },
          value: mm.app.active,
        ),
      );
      list.add(
        ListTile(
          leading: Icon(Icons.watch_later),
          title: Text("${mm.app.stopHour.format(context)}"),
          onTap: () async {
            TimeOfDay? timePicked = await showTimePicker(context: context, initialTime: mm.app.stopHour);
            if (timePicked != null){
              mm.app.stopHour = timePicked;
              mm.updateApp();
            }
          },
        )
      );
    }

    return list;
  }
}
