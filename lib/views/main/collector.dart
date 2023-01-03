
import 'package:animations/animations.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../../routes/route_generator.dart';
import '../shimmer.dart';
import '../views.dart';

class CollectorPage extends StatefulWidget {
  const CollectorPage({Key? key}) : super(key: key);

  @override
  State<CollectorPage> createState() => _CollectorPageState();
}

class _CollectorPageState extends State<CollectorPage> {
  bool loading = true;
  bool recolecting = false;
  late ModelsManager mm;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  PadlockFilter padlockFilter = PadlockFilter(users: []);

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      setState(() {
        endDate = mostRecentSunday(DateTime.now().subtract(Duration(days: 0)));
        startDate = mostRecentMonday(DateTime.now().subtract(Duration(days: 7)));
        endDate = endDate.add(Duration(hours: 23, minutes: 59, seconds: 59));
      });
      _refresh();
    });
  }
  DateTime mostRecentSunday(DateTime date) => DateTime(date.year, date.month, date.day - date.weekday % 7);
  DateTime mostRecentMonday(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday - 1));
  Future<void> _refresh() async {

    List<int> newList = [mm.selectedCollector!.user];
    newList.addAll(mm.selectedCollector!.listers);
    await mm.updateModels(modelType: ModelType.user,filter: UserFilter(),newList: newList);

    padlockFilter.user.values = mm.selectedCollector!.listers;
    padlockFilter.playing.value = false;
    padlockFilter.listerMoneyCollected.value = null;
    padlockFilter.collectorMoneyCollected.value = null;
    padlockFilter.creAtGt.value = startDate.toUtc().toString();
    padlockFilter.creAtLt.value = endDate.toUtc().toString();

    await mm.updateModels(modelType: ModelType.padlock,filter: padlockFilter);
    if (mm.user.isStaff || mm.user.isSuperuser) {
      padlockFilter.listerMoneyCollected.value = true;
      padlockFilter.collectorMoneyCollected.value = false;
      padlockFilter.creAtGt.value = endDate.toUtc().toString();
      padlockFilter.creAtLt.value = "";
      mm.updateModels(modelType: ModelType.padlock,filter: padlockFilter);
      mm.updateModels(modelType: ModelType.padlock,filter: padlockFilter);
      padlockFilter.creAtLt.value = startDate.toUtc().toString();
      padlockFilter.creAtGt.value = "";
      mm.updateModels(modelType: ModelType.padlock,filter: padlockFilter);
    }else{
      padlockFilter.creAtGt.value = endDate.toUtc().toString();
      padlockFilter.creAtLt.value = "";
      padlockFilter.listerMoneyCollected.value = false;
      padlockFilter.collectorMoneyCollected.value = false;
      mm.updateModels(modelType: ModelType.padlock,filter: padlockFilter);
      padlockFilter.creAtLt.value = startDate.toUtc().toString();
      padlockFilter.creAtGt.value = "";
      mm.updateModels(modelType: ModelType.padlock,filter: padlockFilter);
    }
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);
    return Scaffold(
      appBar: AppBar(
        title: Text("Colector"),
      ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Shimmer(
            child: ShimmerLoading(
              isLoading: (loading && !recolecting),
              child: ListView(
                children: getList(),
              ),
            ),
          ),
        ),

    );
  }
  List<Widget> getList() {
    List<Widget> list = [];


    list.add(
        ListTile(
          title: ElevatedButton(
            child: Text("Elegir un periodo para filtrar por fecha"),
            onPressed: () async {
              DateTimeRange? dateTimeRange = DateTimeRange(
                  start: startDate, end: endDate);

              dateTimeRange = await showDateRangePicker(context: context,
                  initialDateRange: dateTimeRange,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100));
              if (dateTimeRange != null) {
                setState(() {
                  startDate = dateTimeRange!.start;
                  DateTime end = dateTimeRange.end;
                  end = end.add(const Duration(hours: 23, minutes: 59));
                  endDate = end;
                });
                _refresh();
              }
            },
          ),
          subtitle: Text("${DateFormat('yyyy-MMMM-dd HH:mm a').format(
              startDate.toLocal())} \n${DateFormat('yyyy-MMMM-dd hh:mm a')
              .format(endDate.toLocal())}"),
        )
    );

    List<Widget> users = [];
    users.add(Divider());
    int money = 0;
    int totalMoney = 0;
    int moneyNotCollected = 0;
    int moneyNotCollectedInPeriod = 0;
    for (var user in mm.users) {
      if (mm.selectedCollector!.listers.contains(user.id)) {
        money = 0;
        moneyNotCollected = 0;
        for (var padlock in mm.padlocks) {
          if (padlock.user == user.id) {
            if (padlock.createdAt!.isAfter(startDate) &&
                padlock.createdAt!.isBefore(endDate)) {
              money += padlock.moneyGenerated;
              if (!padlock.listerMoneyCollected) {
                moneyNotCollected += padlock.moneyGenerated;
              }
            }
          }
        }
        users.add(
            ListTile(
                leading: Icon(Icons.person),
                title: Text(user.username),
                subtitle: Text(
                    "Generado(periodo): \$${money}\nNo recolectado(periodo): \$${moneyNotCollected}"),
                trailing: (mm.user.isStaff || mm.user.isSuperuser)? null:ElevatedButton(
                  onPressed: (moneyNotCollected != 0) ? () async {
                    recolecting = true;
                    for (var padlock in mm.padlocks) {
                      if (padlock.user == user.id) {
                        if (!padlock.listerMoneyCollected) {
                          padlock.listerMoneyCollected = true;
                          mm.updateModel(modelType: ModelType.padlock,model: padlock);
                        }
                      }
                    }
                    setState(() {
                      recolecting = false;
                    });
                  } : null,
                  child: Text("Recolectar"),
                )
            )
        );
      }
    }
    for (var user in mm.users) {
      if (user.id == mm.selectedCollector!.user) {
        list.add(
            Card(
              child: ExpansionTile(
                  title: ListTile(
                    title: Text("${user.username}"),
                    subtitle: Text(
                        "Id: ${mm.selectedCollector!.id}\n${mm.selectedCollector!
                            .listers.length} ${(mm.selectedCollector!.listers
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
        break;
      }
    }
    money = 0;
    totalMoney = 0;
    moneyNotCollected = 0;
    moneyNotCollectedInPeriod = 0;
    int moneyCollectedInPeriod = 0;
    int moneyCollected = 0;
    for (var padlock in mm.padlocks) {
      if (mm.selectedCollector!.listers.contains(padlock.user)){
        if (padlock.createdAt!.isAfter(startDate) &&
            padlock.createdAt!.isBefore(endDate)) {
          if (padlock.listerMoneyCollected &&
              !padlock.collectorMoneyCollected) {
            moneyNotCollectedInPeriod += padlock.moneyGenerated;
          }
          if (padlock.collectorMoneyCollected) {
            moneyCollectedInPeriod += padlock.moneyGenerated;
          }
          money += padlock.moneyGenerated;
        }
        if (padlock.createdAt!.isAfter(endDate) ||
            padlock.createdAt!.isBefore(startDate)) {
          if (mm.user.isCollector) {
            if (!padlock.listerMoneyCollected) {
              moneyNotCollected += padlock.moneyGenerated;
            }
          }else{
            if (padlock.listerMoneyCollected &&!padlock.collectorMoneyCollected) {
              moneyNotCollected += padlock.moneyGenerated;
            }
          }
        }
        if (padlock.collectorMoneyCollected) {
          moneyCollected += padlock.moneyGenerated;
        }

        totalMoney += padlock.moneyGenerated;
      }
    }
    if (mm.user.isStaff || mm.user.isSuperuser) {

      list.add(
          ListTile(
            title: Text("Dinero generado(periodo): \$${money}"),
          )
      );
      list.add(
          ListTile(
            title: Text("Dinero recolectado (periodo): \$${moneyCollectedInPeriod}"),
          )
      );

      list.add(
          ListTile(
              title: Text(
                  "Dinero no recolectado(periodo): \$${moneyNotCollectedInPeriod}"),
              trailing: ElevatedButton(
                onPressed: (moneyNotCollectedInPeriod == 0)? null:() async {
                  recolecting = true;
                  for (var padlock in mm.padlocks) {
                    if (mm.selectedCollector!.listers.contains(padlock.user)) {
                      if (!padlock.collectorMoneyCollected &&
                          (padlock.createdAt!.isAfter(startDate) &&
                              padlock.createdAt!.isBefore(endDate)) &&
                          padlock.listerMoneyCollected) {
                        padlock.collectorMoneyCollected = true;
                        mm.updateModel(
                            modelType: ModelType.padlock, model: padlock);
                      }
                    }
                  }
                  setState(() {
                    recolecting = false;
                  });
                },
                child: Text("Recolectar"),
              )
          )
      );


    }
    list.add(
        ListTile(
            title: Text(
                "Dinero no recolectado fuera del periodo: \$${moneyNotCollected}"),
            trailing: ElevatedButton(
              onPressed:(moneyNotCollected == 0)? null: () async {
                recolecting = true;

                for (var padlock in mm.padlocks) {
                  if (mm.selectedCollector!.listers.contains(padlock.user)) {
                    if (mm.user.isStaff || mm.user.isSuperuser) {
                      if (!padlock.collectorMoneyCollected &&
                          padlock.listerMoneyCollected) {
                        padlock.collectorMoneyCollected = true;
                        mm.updateModel(
                            modelType: ModelType.padlock,model: padlock);
                      }
                    } else {
                      if (!padlock.collectorMoneyCollected &&
                          !padlock.listerMoneyCollected) {
                        padlock.listerMoneyCollected = true;
                        mm.updateModel(
                            modelType: ModelType.padlock,model: padlock);
                      }
                    }
                  }
                }
                setState(() {
                  recolecting = false;
                });
              },
              child: Text("Recolectar"),
            )
        )
    );
    if (recolecting) {
      list.add(
          ListTile(
            leading: CircularProgressIndicator(),
            title: Text("Recolectando dinero ..."),
          )
      );
    }
    if (mm.user.isSuperuser || mm.user.isStaff) {
      list.add(const Divider());
      list.add(
          ListTile(
            leading: const Icon(Icons.info_outline),
            subtitle: Text(
                "-Si no te aparece el dinero no recolectado es porque primero el colector debe recolectar su dinero."),
          )
      );
    }

    return list;
  }

}
