import 'package:bolita_cubana/filters/filters.dart';
import 'package:bolita_cubana/models/model.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:bolita_cubana/views/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';

class SellPadlocksPage extends StatefulWidget {
  const SellPadlocksPage({Key? key,}): super(key: key);
  @override
  _SellPadlocksPageState createState() => _SellPadlocksPageState();
}

class _SellPadlocksPageState extends State<SellPadlocksPage> {
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
    mm.updateModels(modelType: ModelType.padlock, filter: PadlockFilter(month: (month + 1).toString()));
  }
  @override
  Widget build(BuildContext context) {

    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating );
    return DefaultTabController(
      length: 2,
      child: CustomScaffold(
        appBar: AppBar(
          actions: [
            DropdownButton<String>(
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
          ],
          title: const Text(""),
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
          title: Text("Vender todos los numeros"),
          subtitle: Text("Dinero total: ${moneyGenerated}"),
        )
    );
    list.add(
        Row(
          children: [
            Expanded(child: Text("")),
            ElevatedButton.icon(
              icon:Icon(Icons.auto_graph),
                onPressed: (){
                  for (var padlock in mm.padlocks){
                    if (padlock.month == month +1 && !padlock.selled){
                      padlock.selled = true;
                      mm.updateModel(modelType: ModelType.padlock, model: padlock);
                    }
                  }
                },
                label: Text("Vender todos los numeros")
            ),
            Expanded(child: Text("")),
          ],
        )
    );


    return list;
  }
}