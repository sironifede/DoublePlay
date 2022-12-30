import 'package:bolita_cubana/filters/filters.dart';
import 'package:bolita_cubana/models/model.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:bolita_cubana/views/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';

class EnabledMonthsPage extends StatefulWidget {
  const EnabledMonthsPage({Key? key,}): super(key: key);
  @override
  _EnabledMonthsPageState createState() => _EnabledMonthsPageState();
}

class _EnabledMonthsPageState extends State<EnabledMonthsPage> {
  bool loading = false;
  late ModelsManager mm;
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
    mm.updateModels(modelType: ModelType.month);
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating );
    return CustomScaffold(
      appBar: AppBar(
        title: Text("Meses habilitados"),
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
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];

    for (var month in mm.months){
      list.add(
          CheckboxListTile(
              title: Text('${months[month.id - 1]}'),
              onChanged: (e) {
                month.enabled= !month.enabled;
                mm.updateModel(modelType: ModelType.month,model: month);
              },
              value: month.enabled
          )
      );
    }
    return list;
  }
}