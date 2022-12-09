
import 'package:animations/animations.dart';
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
  DateTime sunday = DateTime.now();
  DateTime monday = DateTime.now();

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      setState(() {
        sunday = mostRecentSunday(DateTime.now().subtract(Duration(days: 0)));
        monday = mostRecentMonday(DateTime.now().subtract(Duration(days: 7)));
        sunday = sunday.add(Duration(hours: 23, minutes: 59, seconds: 59));
      });
      _refresh();
    });
  }
  DateTime mostRecentSunday(DateTime date) => DateTime(date.year, date.month, date.day - date.weekday % 7);
  DateTime mostRecentMonday(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday -1));
  Future<void> _refresh() async {
    await mm.updateUsers();
    await mm.updateCollectors();
    DateTime sunday = mostRecentSunday(DateTime.now().subtract(Duration(days: 0)));
    DateTime monday = mostRecentMonday(DateTime.now().subtract(Duration(days: 7)));
    sunday = sunday.add(Duration(hours: 23, minutes: 59, seconds: 59));
    print(monday);
    print(sunday);
    mm.padlocks = [];
    for (var user in mm.users) {
      if (mm.selectedCollector.listers.contains(user.id)) {
        mm.updatePadlocks(
            loadMore: true,
            filter: PadlockFilter(user: user.id.toString()));
      }
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
  List<Widget> getList(){
    List<Widget> list = [];





    list.add(
        ListTile(
          title: ElevatedButton(
            child:Text("Elegir un periodo para filtrar por fecha"),
            onPressed: () async {
              DateTimeRange? dateTimeRange = DateTimeRange(start: monday, end: sunday);

              dateTimeRange = await showDateRangePicker(context: context,initialDateRange: dateTimeRange, firstDate: DateTime(1900), lastDate: DateTime(2100));
              if (dateTimeRange != null){
                setState(() {
                  monday = dateTimeRange!.start;
                  DateTime end = dateTimeRange.end;
                  end = end.add(const Duration(hours: 23, minutes: 59)) ;
                  sunday = end;
                });
              }
            },
          ),
          subtitle: Text("${DateFormat('yyyy-MMMM-dd hh:mm a').format(monday.toLocal())} \n${DateFormat('yyyy-MMMM-dd hh:mm a').format(sunday.toLocal())}"),
        )
    );

    List<Widget> users = [];
    users.add(Divider());
    int money = 0;
    int totalMoney = 0;
    int moneyNotCollected = 0;
    int moneyNotCollectedInPeriod = 0;
    for (var user in mm.users){
      if (mm.selectedCollector.listers.contains(user.id)) {
        money = 0;
        moneyNotCollected = 0;
        for (var padlock in mm.padlocks) {
          if (padlock.user.id == user.id){
            if (padlock.createdAt!.isAfter(monday) && padlock.createdAt!.isBefore(sunday)) {
              money += padlock.moneyGenerated;
              if (!padlock.moneyCollected){
                moneyNotCollected += padlock.moneyGenerated;
              }
            }

          }
        }
        users.add(
            ListTile(
              leading: Icon(Icons.person),
              title: Text(user.username),
              subtitle: Text("Generado(periodo): \$${money}\nNo recolectado(periodo): \$${moneyNotCollected}"),
                trailing: ElevatedButton(
                  onPressed: (moneyNotCollected != 0 && (mm.user.isSuperuser || mm.user.isStaff))? () async {
                    recolecting = true;
                    for (var padlock in mm.padlocks) {
                      if (padlock.user.id == user.id) {
                        if (!padlock.moneyCollected) {
                          padlock.moneyCollected = true;
                          await mm.updatePadlock(model: padlock);
                        }
                      }
                    }
                    setState(() {
                      recolecting = false;
                    });
                  }: null,
                  child: Text("Recolectar"),
                )
            )
        );
      }
    }
    list.add(
        Card(
          child: ExpansionTile(
              title: ListTile(
                title: Text("${mm.selectedCollector.user.username}"),
                subtitle: Text("Id: ${mm.selectedCollector.id}\n${mm.selectedCollector.listers.length} ${(mm.selectedCollector.listers.length == 1)? "listero":"listeros"}\nColector creado: ${(mm.selectedCollector.user.dateJoined == null)
                    ? "No se sabe"
                    : DateFormat('yyyy-MMMM-dd hh:mm a').format(mm.selectedCollector.user.dateJoined!.toLocal())}"),
              ),
              children: users
          ),
        )
    );
    money = 0;
    totalMoney = 0;
    moneyNotCollected = 0;
    moneyNotCollectedInPeriod = 0;
    for (var padlock in mm.padlocks) {
      if (padlock.createdAt!.isAfter(monday) && padlock.createdAt!.isBefore(sunday)) {
        if (!padlock.moneyCollected){
          moneyNotCollectedInPeriod += padlock.moneyGenerated;
        }
        money += padlock.moneyGenerated;
      }
      if (!padlock.moneyCollected){
        moneyNotCollected += padlock.moneyGenerated;
      }
      totalMoney += padlock.moneyGenerated;
    }
    list.add(
        ListTile(
          title: Text("Dinero generado(periodo): \$${money}"),
        )
    );
    list.add(
        ListTile(
          title: Text("Dinero generado total: \$${totalMoney}"),
        )
    );
    list.add(
        ListTile(
          title: Text("Dinero no recolectado(periodo): \$${moneyNotCollectedInPeriod}"),
            trailing: ElevatedButton(
              onPressed: (moneyNotCollectedInPeriod != 0 && (mm.user.isSuperuser || mm.user.isStaff))? () async {
                recolecting = true;
                for (var padlock in mm.padlocks) {
                  if (!padlock.moneyCollected && (padlock.createdAt!.isAfter(monday) && padlock.createdAt!.isBefore(sunday))) {
                    padlock.moneyCollected = true;
                    await mm.updatePadlock(model: padlock);
                  }
                }
                setState(() {
                  recolecting = false;
                });
              }: null,
              child: Text("Recolectar"),
            )
        )
    );
    list.add(
        ListTile(
            title: Text("Dinero no recolectado total: \$${moneyNotCollected}"),
            trailing: ElevatedButton(
              onPressed: (moneyNotCollected != 0 && (mm.user.isSuperuser || mm.user.isStaff))? () async {
                recolecting = true;
                for (var padlock in mm.padlocks) {
                  if (!padlock.moneyCollected) {
                    padlock.moneyCollected = true;
                    await mm.updatePadlock(model: padlock);
                  }
                }
                setState(() {
                  recolecting = false;
                });
              }: null,
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

    return list;
  }

}
