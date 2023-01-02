import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../filters/play.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../shimmer.dart';

class SearchPlayPage extends StatefulWidget {
  const SearchPlayPage({Key? key}) : super(key: key);

  @override
  State<SearchPlayPage> createState() => _SearchPlayPageState();
}

class _SearchPlayPageState extends State<SearchPlayPage> {
  bool loading = true;
  late ModelsManager mm;
  PlayFilter playFilter = PlayFilter();

  TextEditingController _dayNumberController = TextEditingController();
  TextEditingController _nightNumberController = TextEditingController();


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(const Duration(milliseconds: 1),() async {
      _refresh();
    });
  }
  DateTime mostRecentSunday(DateTime date) => DateTime(date.year, date.month, date.day - date.weekday % 7);
  DateTime mostRecentMonday(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday -1));
  Future<void> _refresh() async {
    if (_dayNumberController.text != "") {
      if (_nightNumberController.text != "") {
        ModelOptions modelOptions = await mm.updateModels(
            modelType: ModelType.play, filter: playFilter);
        List<int> padlocks = [];

        for (var model in modelOptions.fetchedModels.models) {
          if (!padlocks.contains((model as Play).padlock)) {
            padlocks.add((model as Play).padlock);

          }
        }
        print(padlocks);
        modelOptions = await mm.updateModels(modelType: ModelType.padlock,
            filter: PadlockFilter(),
            newList: padlocks);
        List<int> users = [];
        for (var model in modelOptions.fetchedModels.models) {
          if (!users.contains((model as Padlock).user)) {
            users.add((model as Padlock).user);
          }
        }
        await mm.updateModels(modelType: ModelType.collector);
        for (var collector in mm.collectors) {
          users.add(collector.id);
        }
        mm.updateModels(
            modelType: ModelType.user, filter: UserFilter(), newList: users);
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Buscar jugada"),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child:Shimmer(
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

    list.add(
      TextField(
          enabled: !loading,
          controller: _dayNumberController ,
          decoration: InputDecoration(
              labelText: "Numero dia",
              hintText: "Numero de dia",
              icon: const Icon(Icons.numbers),
          )
      ),
    );
    list.add(
      TextField(
          enabled: !loading,
          controller: _nightNumberController ,
          decoration: InputDecoration(
            labelText: "Numero noche",
            hintText: "Numero de noche",
            icon: const Icon(Icons.numbers),
          )
      ),
    );
    list.add(
        Row(
            children: [
              Expanded(child: Text("")),
              ElevatedButton.icon(
                  onPressed: () async {
                    mm.plays = [];
                    playFilter.dayNumber.value = _dayNumberController.text;
                    playFilter.nightNumber.value = _nightNumberController.text;

                    playFilter.type.value = "";
                    _refresh();

                    playFilter.dayNumber.value = _nightNumberController.text;
                    playFilter.nightNumber.value = _dayNumberController.text;
                    playFilter.type.value = "JDA";
                    _refresh();
                    playFilter.type.value = "JD";
                    _refresh();

                  },
                  icon: Icon(Icons.search),
                  label: Text("Buscar jugadas")
              ),
              Expanded(child: Text("")),
            ]
        )
    );
    bool blank = true;
    for (var collector in mm.collectors){
      bool add = false;
      for (var play in mm.plays){
        for (var padlock in mm.padlocks){
          if (padlock.id ==play.padlock){
            if (collector.listers.contains(padlock.user)){

              add = true;
            }
            break;
          }

        }

      }

      if (add) {
        blank = false;
        List<Widget> users = [];
        users.add(Divider());
        for (var user in mm.users){
          if (collector.listers.contains(user.id)){
            List<Widget> plays = [];
            for (var play in mm.plays){

              for (var padlock in mm.padlocks){
                if (padlock.user == user.id){
                  if(play.padlock == padlock.id){
                    bool addPlay = false;
                    int dayNumber = -1;
                    int nightNumber = -1;
                    try{
                      dayNumber = int.parse(_dayNumberController.text);
                      nightNumber = int.parse(_nightNumberController.text);
                    }catch(e){}
                    if (nightNumber != -1 && dayNumber != -1) {
                      if ([PlayType.JDA, PlayType.JD].contains(play.type)) {
                        if (play.dayNumber == nightNumber && play.nightNumber == dayNumber) {
                          addPlay = true;
                        }
                      }
                      if (play.dayNumber == dayNumber && play.nightNumber == nightNumber) {
                        addPlay = true;
                      }
                    }
                    if (addPlay){
                      plays.add(
                          Card(
                              child: ListTile(
                                onTap: (){

                                  mm.selectedPadlock = padlock;
                                  Navigator.of(context).pushNamed(Routes.padlock);
                                },
                                title: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text("Para el mes: ${padlock.month}"),
                                      subtitle: Text("Tipo de jugada: ${play.type?.name}"),
                                      trailing: Text("#${padlock.id.toString().padLeft(8, '0')}"),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(60)
                                                //more than 50% of width makes circle
                                              ),
                                              child: Center(child: Text("${play.dayNumber.toString().padLeft(3, '0')}")),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.circular(60)
                                                //more than 50% of width makes circle
                                              ),
                                              child: Center(child: Text("${play.nightNumber.toString().padLeft(3, '0')}")),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(60)
                                                //more than 50% of width makes circle
                                              ),
                                              child: Center(child: Text("\$${play.bet}")),
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:  Text("Realizada: ${(play.createdAt == null)? "No se sabe": DateFormat('yyyy-MMMM-dd HH:mm a').format(play.createdAt!.toLocal())}"),
                                    )

                                  ],
                                ),
                              )
                          )
                      );
                    }
                    break;
                  }
                }
              }

            }
            if (plays.length > 0) {
              users.add(
                ExpansionTile(
                    title: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(user.username),
                      subtitle: Text("Jugadas: ${plays.length}"),
                    ),
                    children: plays
                ),

              );
            }

          }
        }
        for (var user in mm.users) {
          if (collector.user == user.id) {
            list.add(
                Card(
                  child: ExpansionTile(
                      title: ListTile(
                        title: Text("${user.username}"),
                        subtitle: Text("Id: ${collector.id}\n${collector.listers
                            .length} ${(collector.listers.length == 1)
                            ? "listero"
                            : "listeros"} \nColector creado: ${(user
                            .dateJoined == null)
                            ? "No se sabe"
                            : DateFormat('yyyy-MMMM-dd HH:mm a').format(user.dateJoined!.toLocal())}"),
                      ),
                      children: users
                  ),
                )
            );
          }
        }

      }
    }
    if (blank){
      list.add(
          ListTile(
              title: Text("No hay jugadas con esos numeros"),
          )
      );
    }
    list.add(const Divider());
    list.add(
        ListTile(
            leading:const Icon(Icons.info_outline),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    children: [
                      const Text("-Toca en "),
                      const Icon(Icons.filter_alt),
                      const Text(" para filtrar las jugadas")
                    ]
                ),
                Row(
                  children: [
                    const Text("-Este circulo "),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(60)
                        //more than 50% of width makes circle
                      ),
                      child: const Text(""),
                    ),
                    const Text(" es el numero de dia")
                  ],
                ),
                Row(
                  children: [
                    const Text("-Este circulo "),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(60)
                        //more than 50% of width makes circle
                      ),
                      child: const Text(""),
                    ),
                    const Text(" es el numero de noche")
                  ],
                ),
                Row(
                  children: [
                    const Text("-Este circulo "),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(60)
                        //more than 50% of width makes circle
                      ),
                      child: const Center(child: Text("\$")),
                    ),
                    const Text(" es el dinero de la apuesta")
                  ],
                ),
              ],
            )
        )
    );

    return list;
  }
}
