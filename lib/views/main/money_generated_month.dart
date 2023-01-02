import 'package:bolita_cubana/filters/filters.dart';
import 'package:bolita_cubana/models/model.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:bolita_cubana/views/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';

class MoneyGeneratedInMonthPage extends StatefulWidget {
  const MoneyGeneratedInMonthPage({Key? key,}): super(key: key);
  @override
  _MoneyGeneratedInMonthPageState createState() => _MoneyGeneratedInMonthPageState();
}

class _MoneyGeneratedInMonthPageState extends State<MoneyGeneratedInMonthPage> {
  bool loading = false;
  late ModelsManager mm;
  int month = DateTime.now().month - 1;
  int year = DateTime.now().year;
  List<String> months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  PadlockFilter padlockFilter = PadlockFilter();

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      startDate = DateTime(year, month + 1, 1, 0, 0);
      int sum = 0;
      int mon = month + 1;
      if (month == 11 ){
        sum = 1;
        mon = 1;
      }
      if (month == 0){
        mon = 2;
      }
      endDate = DateTime(year + sum, mon, 0, 23, 59);
      padlockFilter.creAtLt.value = startDate.toString();
      padlockFilter.creAtLt.value = endDate.toString();
      _refresh();
    });
  }
  Future<void> _refresh() async {
    await mm.updateModels(modelType: ModelType.padlock, filter: padlockFilter);
    await mm.updateModels(modelType: ModelType.collector);
    List<int> users = [];
    for (var padlock in mm.padlocks){
      if (endDate.isAfter(padlock.createdAt!) && startDate.isBefore(padlock.createdAt!)) {
        if (!users.contains(padlock.user)){
          users.add(padlock.user);
        }
        for (var collector in mm.collectors){
          if (collector.listers.contains(padlock.user)){
            if (!users.contains(collector.user)){
              users.add(collector.user);
            }
            break;
          }
        }
      }
    }
    mm.updateModels(modelType: ModelType.user, filter: UserFilter(), newList: users);
  }
  @override
  Widget build(BuildContext context) {
    List<int> years = [];
    for (int i= year - 5; i < (year + 5); i++){
      years.add(i);
    }
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating );
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              DropdownButton<int>(
                value: year,
                onChanged: (int? value) async {
                  if (value != null) {
                    year = value;
                    startDate = DateTime(year, month + 1, 1, 0, 0);
                    int sum = 0;
                    int mon = month + 1;
                    if (month == 11 ){
                      sum = 1;
                      mon = 1;
                    }
                    if (month == 0){
                      mon = 2;
                    }
                    endDate = DateTime(year + sum, mon, 0, 23, 59);
                    padlockFilter.creAtLt.value = startDate.toString();
                    padlockFilter.creAtLt.value = endDate.toString();
                    _refresh();
                  }
                },
                items: years.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value"),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: months[month],
                onChanged: (String? value) async {
                  for (int i = 0; i < months.length; i++) {
                    if (months[i] == value) {
                      month = i;
                      startDate = DateTime(year, month + 1, 1, 0, 0);
                      endDate = DateTime(year, month + 2, 0, 23, 59);
                      padlockFilter.creAtLt.value = startDate.toString();
                      padlockFilter.creAtLt.value = endDate.toString();
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
    print(startDate);
    print(endDate);
    int i = 0;

    for (var padlock in mm.padlocks){

      if (endDate.isAfter(padlock.createdAt!) && startDate.isBefore(padlock.createdAt!)) {
        i ++;
        moneyGenerated += padlock.moneyGenerated;
      }
    }
    print(i);
    List<Widget> collectors = [];
    for (var collector in mm.collectors){
      List<Widget> users = [];

      for (var user in mm.users){
        int userMoney = 0;
        if (collector.listers.contains(user.id)) {
          for (var padlock in mm.padlocks) {
            if (padlock.user == user.id) {
              if (endDate.isAfter(padlock.createdAt!) &&
                  startDate.isBefore(padlock.createdAt!)) {
                userMoney += padlock.moneyGenerated;
              }
            }
          }
          users.add(
              ListTile(
                  leading: Icon(Icons.person),
                  title: Text(user.username),
                  subtitle: Text("Generado: \$${userMoney}"),
              )
          );
        }
      }
      for (var user in mm.users){
        if (collector.user == user.id) {
          collectors.add(
              Card(
                child: ExpansionTile(
                    title: ListTile(
                      title: Text("${user.username}"),
                      subtitle: Text(
                          "Id: ${collector.id}\n${collector
                              .listers.length} ${(collector.listers
                              .length == 1)
                              ? "listero"
                              : "listeros"}\nColector creado: ${(user.dateJoined == null)
                              ? "No se sabe"
                              : DateFormat('yyyy-MMMM-dd hh:mm a').format(user.dateJoined!.toLocal())}"),
                    ),
                    children: users
                ),
              )
          );
        }
      }
    }


    list.add(
        ExpansionTile(
            title: ListTile(
              title: Text("Dinero Genereado: \$${moneyGenerated}"),
            ),
            children: collectors
        ),

    );


    List<int> moneyMonths = List<int>.filled(12, 0, growable: false);
    List<int> moneyMonthsLister = List<int>.filled(12, 0, growable: false);
    List<int> moneyMonthsCollector = List<int>.filled(12, 0, growable: false);
    for (var padlock in mm.padlocks){

      if (endDate.isAfter(padlock.createdAt!) && startDate.isBefore(padlock.createdAt!)) {
        moneyMonths[padlock.month - 1] += padlock.moneyGenerated;
        if (padlock.listerMoneyCollected){
          moneyMonthsLister[padlock.month - 1] += padlock.moneyGenerated;
        }
        if (padlock.collectorMoneyCollected){
          moneyMonthsCollector[padlock.month - 1] += padlock.moneyGenerated;
        }
      }
    }

    for (int i = 0; i < 12;i ++){
      List<Widget> collectors = [];
      for (var collector in mm.collectors){
        List<Widget> users = [];

        for (var user in mm.users){

          if (collector.listers.contains(user.id)) {
            int userMoney = 0;
            for (var padlock in mm.padlocks) {
              if (padlock.user == user.id) {
                if (endDate.isAfter(padlock.createdAt!) &&
                    startDate.isBefore(padlock.createdAt!)) {
                  if (padlock.month - 1 == i) {
                    userMoney += padlock.moneyGenerated;
                  }
                }
              }
            }
            users.add(
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(user.username),
                  subtitle: Text("Generado: \$${userMoney}"),
                )
            );
          }
        }
        for (var user in mm.users){
          if (collector.user == user.id) {
            collectors.add(
                Card(
                  child: ExpansionTile(
                      title: ListTile(
                        title: Text("${user.username}"),
                        subtitle: Text(
                            "Id: ${collector.id}\n${collector
                                .listers.length} ${(collector.listers
                                .length == 1)
                                ? "listero"
                                : "listeros"}\nColector creado: ${(user.dateJoined == null)
                                ? "No se sabe"
                                : DateFormat('yyyy-MMMM-dd hh:mm a').format(user.dateJoined!.toLocal())}"),
                      ),
                      children: users
                  ),
                )
            );
          }
        }
      }
      if (moneyMonths[i] != 0) {
        list.add(Divider());
        list.add(
            ExpansionTile(
                title: ListTile(
                  title: Text(
                      "Dinero de jugadas para ${months[i]}: \$${moneyMonths[i]}"),
                  subtitle: Text(
                      "Dinero recolectado por collectores: \$${moneyMonthsLister[i]}\nDinero recolectado por administradores: \$${moneyMonthsCollector[i]}"),
                ),
                children: collectors
            ),

        );
      }
    }



    return list;
  }
}