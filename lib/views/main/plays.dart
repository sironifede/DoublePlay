import 'package:bolita_cubana/api_connection/api.dart';
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

class PlaysPage extends StatefulWidget {
  const PlaysPage({Key? key}) : super(key: key);

  @override
  State<PlaysPage> createState() => _PlaysPageState();
}

class _PlaysPageState extends State<PlaysPage> {

  int totalBet = 0;
  bool loading = true;
  bool filtering = false;
  bool addingModels = false;
  late ModelsManager mm;

  ModelOptions playModelOptions = ModelOptions(fetchedModels: FetchedModels(hasMore: false, models: []),hasError: false, page: 1);

  bool selectingElements = true;
  List<PlayElement> elements = [];

  List<String> months = <String>['', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  String month = '';
  List<String> playTypes = <String>['', 'JS', 'JSA', 'JD', 'JDA'];
  String playType = '';
  PlayFilter playFilter = PlayFilter();
  PadlockFilter padlockFilter = PadlockFilter();
  TextEditingController _padlockId = TextEditingController();

  TextEditingController _betController = TextEditingController();
  TextEditingController _betControllerGT = TextEditingController();

  void handleClick(String value) async {
    switch (value) {
      case "Seleccionar todo":
        setState(() {
          selectingElements = true;
          bool selectAll = false;
          for (var element in elements){
            if (!element.selected){
              selectAll = true;
            }
          }
          for (var element in elements){
            element.selected = selectAll;
          }
        });
        break;
      case "":
        break;

    }
  }
  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(const Duration(milliseconds: 1),() async {
      DateTime sunday = mostRecentSunday(DateTime.now().subtract(Duration(days: 0)));
      DateTime monday = mostRecentMonday(DateTime.now().subtract(Duration(days: 7)));
      sunday = sunday.add(Duration(hours: 23, minutes: 59, seconds: 59));

      playFilter.creAtGt.value = monday.toString();
      playFilter.creAtLt.value = sunday.toString();
      _refresh();
    });
  }

  DateTime mostRecentSunday(DateTime date) => DateTime(date.year, date.month, date.day - date.weekday % 7);
  DateTime mostRecentMonday(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday -1));

  Future<void> _refresh() async {
    playFilter.user.values = [mm.selectedUser!.id];

    playModelOptions = await mm.updateModels(modelType: ModelType.play,filter: playFilter);
    List<int> padlocks = [];
    for (var play in playModelOptions.fetchedModels.models) {
      if(!padlocks.contains((play as Play).padlock)){
        padlocks.add((play as Play).padlock);
      }
    }
    await mm.updateModels(modelType: ModelType.padlock,newList: padlocks,filter: PadlockFilter());
  }

  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);
    if (!selectingElements){
      elements = [];
    }
    totalBet = 0;
    for (var play in mm.plays) {
      bool addP = false;
      if (playFilter.creAtGt.value != "" && playFilter.creAtLt.value != "") {
        if ((play as Play).createdAt!.isAfter(DateTime.parse(playFilter.creAtGt.value)) &&
            (play as Play).createdAt!.isBefore(DateTime.parse(playFilter.creAtLt.value)) &&
            (play as Play).confirmed) {
          addP = true;
        }
      }else{
        addP = true;
      }
      if (addP){
        for (var padlock in mm.padlocks){
          int monthf = -1;
          try{
            monthf = int.parse(playFilter.month.value);
          }catch(e){}
          bool add = true;
          if (monthf != -1){
            if (padlock.month != monthf){
              add = false;
            }
          }
          bool addType = false;
          if (playType != ""){
            if (playType == "JD" && play.type == PlayType.JD){
              addType = true;
            }
            if (playType == "JDA" && play.type == PlayType.JDA){
              addType = true;
            }
            if (playType == "JS" && play.type == PlayType.JS){
              addType = true;
            }
            if (playType == "JSA" && play.type == PlayType.JSA){
              addType = true;
            }
          }else{
            addType = true;
          }

          if (padlock.user == mm.selectedUser!.id && add && addType) {
            if (play.padlock == padlock.id ) {
              int id = -1;
              try{
                id = int.parse(_padlockId.text);
              }catch(e){

              }
              //print("padlock: ${play.padlock}");
              if (id != -1){
                if (padlock.id == id){
                  if (!selectingElements) {
                    elements.add(PlayElement(padlock: padlock, play: play));

                  }
                  totalBet += play.bet;
                  break;
                }
              }else{
                if (!selectingElements) {
                  elements.add(PlayElement(padlock: padlock, play: play));
                }
                totalBet += play.bet;

                break;
              }

            }
          }
        }
      }
    }
    if (!loading) {
      if (filtering) {
        setState(() {
          filtering = false;
        });
      }
      if (addingModels) {
        setState(() {
          addingModels = false;
        });
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Jugadas"),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.filter_alt),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return StatefulBuilder(
                            builder: (context, StateSetter setState) {
                              return AlertDialog(
                                scrollable: true,
                                title: const Text("Filtros"),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(child: Text("Mes de la jugada: ")),
                                        DropdownButton<String>(
                                          value: month,
                                          onChanged: (String? value) {
                                            setState(() {
                                              month = value!;
                                            });
                                          },
                                          items: months.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Expanded(child: Text("Tipo de jugada:")),
                                        DropdownButton<String>(
                                          value: playType,
                                          onChanged: (String? value) {
                                            // This is called when the user selects an item.
                                            setState(() {
                                              playType = value!;
                                            });
                                          },
                                          items: playTypes.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    ListTile(
                                      title: ElevatedButton(
                                        child:Text("Elegir un periodo para filtrar por fecha"),
                                        onPressed: () async {
                                          DateTimeRange? dateTimeRange;
                                          if (playFilter.creAtGt.value != ""){
                                            dateTimeRange = DateTimeRange(start: DateTime.parse(playFilter.creAtGt.value), end: DateTime.parse(playFilter.creAtLt.value));
                                          }
                                          dateTimeRange = await showDateRangePicker(context: context,initialDateRange: dateTimeRange, firstDate: DateTime(1900), lastDate: DateTime(2100));
                                          if (dateTimeRange != null){
                                            setState(() {
                                              playFilter.creAtGt.value = dateTimeRange!.start.toString();
                                              DateTime end = dateTimeRange.end;
                                              end = end.add(const Duration(hours: 23, minutes: 59)) ;
                                              playFilter.creAtLt.value = end.toString();
                                            });
                                          }
                                        },
                                      ),
                                      subtitle: Text("${playFilter.creAtGt.value}\n${playFilter.creAtLt.value}"),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child:const Text("CANCELAR"),
                                    onPressed: (){

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                      onPressed: () async {
                                        playFilter.month.value = month;
                                        playFilter.type.value = playType;
                                        playFilter.bet.value = _betController.text;
                                        playFilter.betGT.value = _betControllerGT.text;
                                        filtering = true;
                                        _refresh();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("FILTRAR")
                                  )
                                ],
                              );
                            }
                        );
                      }
                  );
                }
            ),
            (selectingElements)?IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  bool? result = await showDialog(context: context, builder: (_){
                    return AlertDialog(
                      title: const Text("¿Eliminar los usuarios seleccionados?"),
                      content: const Text("¿Estás seguro de que quieres eliminar las jugadas seleccionados?, no podra recuperarlas"),
                      actions: [
                        TextButton(
                          child:const Text("CANCELAR"),
                          onPressed: (){
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child:const Text("ACEPTAR"),
                          onPressed: (){
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],

                    );
                  });
                  if (result != null){
                    if (result){
                      print("eliminando jugadas");
                      removeElement(1);
                    }
                  }
                }
            ):Text(""),
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {"Seleccionar todo",}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body:
        RefreshIndicator(
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
  void removeElement(int cant){
    var element;
    for (element in elements){
      if (element.selected){
        break;
      }
    }
    setState(() {
      element.deleting = true;
    });
    mm.removeModel(modelType: ModelType.play,model: element.play).then((v) {
      elements.remove(element);
      mm.plays.remove(element.play);
      bool continueDeleting = false;
      for (element in elements){
        if (element.selected){
          continueDeleting = true;
          break;
        }
      }
      if (continueDeleting) {
        print("continuar eliminando");
        cant = cant + 1;
        removeElement(cant);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Se han elimnado $cant jugadas")),
        );
        _refresh();
      }
    });
  }
  List<Widget> getList(){
    List<Widget> list = [];
    list.add(
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(mm.selectedUser!.username),
          subtitle: Text("${(mm.selectedUser!.isSuperuser)? "Superusuario": (mm.selectedUser!.isStaff)?"Admin": "Listero"}"),
        )
    );

    if (elements.isNotEmpty){
      list.add(
          ListTile(
            leading: Text(""),
            title: Text('Jugadas'),
            subtitle: Text('${elements.length}'),
          )
      );
      list.add(
          ListTile(
            leading: Text(""),
            title: Text("Dinero recaudado: \$$totalBet",style:const TextStyle( fontSize: 30)),
            subtitle: Text("Desde: ${playFilter.creAtGt.value}\nHasta: ${playFilter.creAtLt.value}"),
          )
      );
    }else{
      list.add(
          ListTile(
            leading: Text(""),
            title: Text("Dinero recaudado: \$$totalBet",style:const TextStyle( fontSize: 30)),
            subtitle: Text("Desde: ${playFilter.creAtGt.value}\nHasta: ${playFilter.creAtLt.value}"),
          )
      );
      list.add(
          ListTile(
            leading: const Text(""),
            title: Text('No hay Jugadas '),
          )
      );
      list.add(
          const Center(
              child:Icon(Icons.warning)
          )
      );
    }

    list.add(
      TextField(
          enabled: !loading,
          controller: _padlockId,
          decoration: InputDecoration(
              labelText: "Nro. de confirmacion",
              hintText: "Numero de confirmacion",
              icon: const Icon(Icons.numbers),
              suffixIcon:  IconButton(
                icon: const Icon( Icons.search),
                onPressed: () async {
                  setState(() {
                    month = "";
                    playType = "";
                    filtering = true;
                    playFilter.type.value = "";
                    playFilter.creAtLt.value = "";
                    playFilter.creAtGt.value = "";
                    playFilter.month.value = "";
                    try{
                      int id = int.parse(_padlockId.text);
                      playFilter.padlock.values = [id];
                    }catch(e){
                      playFilter.padlock.values = [_padlockId.text];
                    }
                  });

                  _refresh();

                },
              )
          )
      ),
    );
    if (filtering){
      list.add(
          const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Filtrando jugadas'),
          )
      );
    }

    bool isSelectingElements = false;
    for (int i = 0;i < elements.length; i++) {
      if (elements[i].selected) {
        isSelectingElements = true;
      }
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PlayWidget(
            index: i +1 ,
            element: elements[i],
            onTap: () {
              if (selectingElements) {
                setState(() {
                  elements[i].selected = !elements[i].selected;
                });
              }else{
                mm.selectedPadlock = elements[i].padlock;
                Navigator.of(context).pushNamed(Routes.padlock);
              }
            },
            onLongPress:(mm.user.isSuperuser || mm.user.isStaff)? () {
              if (!selectingElements) {
                setState(() {
                  selectingElements = true;
                });
              }
              setState(() {
                elements[i].selected = !elements[i].selected;
              });
            }: null,
            selectingElements: selectingElements,
          ),
        ),
      );

    }
    if (!isSelectingElements && selectingElements){
      Future.delayed(const Duration(milliseconds: 1),(){
        setState(() {
          selectingElements = false;
        });
      });
    }
    if (playModelOptions.fetchedModels.hasMore){
      if (addingModels){
        list.add(
          const Center(
            child: CircularProgressIndicator()
          )
        );
      }else{
        list.add(
          Center(
            child:IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                addingModels = true;
                playModelOptions.page ++;
                playModelOptions = await mm.updateModels(modelType: ModelType.play,filter: playFilter,page: playModelOptions.page);
              },
            )
          )
        );
      }
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
class PlayElement {
  final Play play;
  final Padlock padlock;
  bool selected;
  bool deleting = false;
  PlayElement({required this.padlock, required this.play, this.selected = false});
}
class PlayWidget extends StatelessWidget {
  const PlayWidget({required this.element, required this.onTap, this.onLongPress, this.selectingElements = false, required this.index});
  final PlayElement element;
  final int index;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final bool selectingElements;
  @override
  Widget build(BuildContext context){
    return Card(
      child: ListTile(
        selected: element.selected,
        onLongPress: onLongPress,
        onTap: onTap,
        title: Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: (selectingElements)?(element.deleting)?const CircularProgressIndicator():Checkbox(
                value: element.selected,
                onChanged: (b){}
              ):null,
              title: Text("Para el mes: ${element.padlock.month}"),
              subtitle: Text("Tipo de jugada: ${element.play.type?.name}"),
              trailing: Text("#${element.padlock.id.toString().padLeft(8, '0')}"),
            ),
            (element.deleting)?const Text("Eliminando jugada..."): const Text(""),
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
                      ),
                      child: Center(child: Text("${element.play.dayNumber.toString().padLeft(3, '0')}")),
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
                      ),
                      child: Center(child: Text("${element.play.nightNumber.toString().padLeft(3, '0')}")),
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
                      child: Center(child: Text("\$${element.play.bet}")),
                    ),
                  ),
                ),

              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:  Text("Realizada: ${(element.play.createdAt == null)? "No se sabe": DateFormat('yyyy-MMMM-dd HH:mm a').format(element.play.createdAt!.toLocal())}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:  Text("Jugada Nro: $index"),
            )
          ],
        ),
      )


    );
  }
}

