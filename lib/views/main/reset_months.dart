import 'package:bolita_cubana/filters/filters.dart';
import 'package:bolita_cubana/models/model.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:bolita_cubana/views/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';

class ResetMonthsPage extends StatefulWidget {
  const ResetMonthsPage({Key? key,}): super(key: key);
  @override
  _ResetMonthsPageState createState() => _ResetMonthsPageState();
}

class _ResetMonthsPageState extends State<ResetMonthsPage> {
  bool loading = false;
  late ModelsManager mm;
  int month = 0;
  List<String> months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ];


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      _refresh();
    });
  }
  Future<void> _refresh() async {
    mm.updateModels(modelType: ModelType.padlock, filter: PadlockFilter(month: (month + 1).toString(),selled: false));
  }
  @override
  Widget build(BuildContext context) {

    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(

          title: const Text("Resetear mes"),
        ),
        body:RefreshIndicator(
          onRefresh: _refresh,
          child: Shimmer(
            child: ShimmerLoading(
              isLoading: loading,
              child: ListView(
                  children:generateColumn()
              ),
            ),
          ),
        )
      ),
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];

    int moneyGenerated = 0;
    for (var padlock in mm.padlocks){
      if (padlock.month == month +1 && !padlock.selled){
        moneyGenerated += padlock.moneyGenerated;
      }
    }

    list.add(
      ListTile(
        title: Text("Elegir mes:"),
        trailing: DropdownButton<String>(
          value: months[month],
          onChanged: (String? value) async {
            for (int i = 0; i < months.length; i++) {
              if (months[i] == value) {
                month = i;
                _refresh();
                break;
              }
            }
          },
          items: months.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      )
    );
    list.add(Divider());
    bool alreadyReset = true;
    for (var padlock in mm.padlocks){
      if (padlock.month == month +1 && !padlock.selled){
        alreadyReset = false;
        break;
      }
    }
    list.add(
        Row(
          children: [
            Expanded(child: Text("")),
            ElevatedButton(
                onPressed: (alreadyReset)?null:  (){
                  for (var padlock in mm.padlocks){
                    if (padlock.month == month +1 && !padlock.selled){
                      padlock.selled = true;
                      mm.updateModel(modelType: ModelType.padlock, model: padlock);
                    }
                  }
                },
                child: Text("RESETEAR")
            ),
            Expanded(child: Text("")),
          ],
        )
    );
    if(alreadyReset){
      list.add(Divider());
      list.add(
          ListTile(
            leading: Icon(Icons.info),

            subtitle: Text("-Ya se resetearon todas las jugadas.\n"),
          )
      );
    }



    return list;
  }
}