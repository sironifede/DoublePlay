import 'package:bolita_cubana/models/app.dart';
import 'package:bolita_cubana/models/model.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';
import '../shimmer.dart';

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
      _refresh();
    });
  }
  Future<void> _refresh() async {
    mm.app = await mm.getModel(modelType: ModelType.app, model: App(id: 1,active: false, stopHour: TimeOfDay.now(), stopHour2: TimeOfDay.now())) as App;
  }

  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return CustomScaffold(
        appBar: AppBar(
          title: const Text("Estado de la app"),
        ),
        body:
        RefreshIndicator(
          onRefresh: _refresh,
          child:Shimmer(
            child: ShimmerLoading(
              isLoading: mm.status == ModelsStatus.updating,
              child: ListView(
                children: generateColumn(),
              ),
            ),
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
        CheckboxListTile(
          title: Text("Aplicacion habilitada"),
          onChanged: (b){
            mm.app.active = !mm.app.active;
            mm.updateModel(modelType: ModelType.app, model: mm.app);
          },
          value: mm.app.active,
        ),
      );
      list.add(
        ListTile(
          leading: Icon(Icons.watch_later),
          title: Text("${mm.app.stopHour.format(context)}"),
          trailing: ElevatedButton(
              child: Text("HORA DE DIA"),
              onPressed: () async {
                TimeOfDay? timePicked = await showTimePicker(context: context, initialTime: mm.app.stopHour);
                if (timePicked != null){
                  mm.app.stopHour = timePicked;
                  mm.updateModel(modelType: ModelType.app, model: mm.app);
                }
              },
          ),
        )
      );
      list.add(
          ListTile(
            leading: Icon(Icons.watch_later),
            title: Text("${mm.app.stopHour2.format(context)}"),
            trailing: ElevatedButton(
              child: Text("HORA DE NOCHE"),
              onPressed: ()async{
                TimeOfDay? timePicked = await showTimePicker(context: context, initialTime: mm.app.stopHour2);
                if (timePicked != null){
                  mm.app.stopHour2 = timePicked;
                  mm.updateModel(modelType: ModelType.app, model: mm.app);
                }
              }
            ),

          )
      );
    }

    return list;
  }
}
