
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
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

  late ModelsManager mm;
  late CollectorElement collectorElement;


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      _refresh();
    });
  }
  DateTime mostRecentSunday(DateTime date) => DateTime(date.year, date.month, date.day - date.weekday % 7);
  DateTime mostRecentMonday(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday -1));
  Future<void> _refresh() async {
    collectorElement = CollectorElement(collector: mm.selectedCollector);
    await mm.updateUsers();
    await mm.updateCollectors();
    mm.padlocks = [];
    DateTime sunday = mostRecentSunday(DateTime.now().subtract(Duration(days: 0)));
    DateTime monday = mostRecentMonday(DateTime.now().subtract(Duration(days: 7)));
    sunday = sunday.add(Duration(hours: 23, minutes: 59, seconds: 59));
    print(monday);
    print(sunday);
    mm.padlocks = [];
    for (var user in mm.users) {
      if (mm.selectedCollector.listers.contains(user.id)) {
        await mm.updatePadlocks(
            loadMore: true,
            filter: PadlockFilter(user: user.id.toString(),
                creAtGt: monday.toLocal().toString(),
                creAtLt: sunday.toLocal().toString()));
      }
    }
    mm.plays = [];
    for (var padlock in mm.padlocks){
      mm.updatePlays(loadMore: true, filter: PlayFilter(padlock: padlock.id.toString()));
    }
    for (var play in mm.plays){
      print(play.id);
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
              isLoading: loading,
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
    int money = 0;
    int moneyN = 0;
    for ( var play in mm.plays){
      money += play.bet;
    }
    DateTime sunday = mostRecentSunday(DateTime.now().subtract(Duration(days: 0)));
    DateTime monday = mostRecentMonday(DateTime.now().subtract(Duration(days: 7)));
    sunday = sunday.add(Duration(hours: 23, minutes: 59, seconds: 59));
    print(moneyN);

    list.add(
      CheckboxListTile(
        title: Text("Dinero recolectado"),
        onChanged:(mm.user.isStaff || mm.user.isSuperuser)? (b){
          mm.selectedCollector.moneyCollcted = !mm.selectedCollector.moneyCollcted;
          mm.updateCollector(model: mm.selectedCollector);
        }:null,
        value: mm.selectedCollector.moneyCollcted,
      ),
    );
    list.add(
        ListTile(
          title: Text("Dinero recaudado de la ultima semana: ${money}\$"),
          subtitle: Text("Desde: ${monday.toLocal()}\nHasta: ${sunday.toLocal()}"),

        )
    );
    List<Widget> users = [];
    users.add(Divider());

    for (var user in mm.users){
      if (mm.selectedCollector.listers.contains(user.id)) {
        int money = 0;
        for (var play in mm.plays) {
          if (play.padlock.user.id == user.id){
            money += play.bet;
          }
        }
        users.add(
            ListTile(
              leading: Icon(Icons.person),
              title: Text(user.username),
              subtitle: Text("Dinero recaudado por listero: ${money}\$"),
            )
        );
      }
    }
    list.add(
        Card(
          child: ExpansionTile(
              title: ListTile(
                title: Text("Id: ${mm.selectedCollector.id} | '${mm.selectedCollector.user.username}'"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${mm.selectedCollector.listers.length} ${(mm.selectedCollector.listers.length == 1)? "listero":"listeros"}"),
                    Text("Colector creado: ${(mm.selectedCollector.user.dateJoined == null)
                        ? "No se sabe"
                        : mm.selectedCollector.user.dateJoined!.toLocal().toString().split(
                        ".")[0]}"),
                  ],
                ),
              ),
              children: users
          ),
        )
    );

    return list;
  }

}
