import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../filters/play.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';

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

  ModelOptions playModelOptions = ModelOptions(hasMore: false, page: 1);

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
      DateTime sunday = mostRecentSunday(DateTime.now().subtract(Duration(days: 7)));
      DateTime saturday = mostRecentSaturday(DateTime.now().subtract(Duration(days: 7)));
      saturday = saturday.add(Duration(hours: 23, minutes: 59, seconds: 59));

      padlockFilter.creAtGt.value = sunday.toString();
      padlockFilter.creAtLt.value = saturday.toString();
      refresh();
    });
  }
  DateTime mostRecentSunday(DateTime date) => DateTime(date.year, date.month, date.day - date.weekday % 7);
  DateTime mostRecentSaturday(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday -6));
  void refresh() async {
    padlockFilter.user.value = mm.selectedUser.id.toString();
    await mm.updatePadlocks(filter: padlockFilter);
    playModelOptions = await mm.updatePlays(filter: playFilter);

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
      if (!selectingElements){
        elements.add(PlayElement(play: play));
      }
      if (play.type == PlayType.JS || play.type == PlayType.JSA){
        totalBet += play.bet;
      }else{
        totalBet += play.bet * 2;
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
                                          if (padlockFilter.creAtGt.value != ""){
                                            dateTimeRange = DateTimeRange(start: DateTime.parse(padlockFilter.creAtGt.value), end: DateTime.parse(padlockFilter.creAtLt.value));
                                          }
                                          dateTimeRange = await showDateRangePicker(context: context,initialDateRange: dateTimeRange, firstDate: DateTime(1900), lastDate: DateTime(2100));
                                          if (dateTimeRange != null){
                                            setState(() {
                                              padlockFilter.creAtGt.value = dateTimeRange!.start.toString();
                                              DateTime end = dateTimeRange.end;
                                              end = end.add(const Duration(hours: 23, minutes: 59)) ;
                                              padlockFilter.creAtLt.value = end.toString();
                                            });
                                          }
                                        },
                                      ),
                                      subtitle: Text("${padlockFilter.creAtGt.value} | ${padlockFilter.creAtLt.value}"),
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
                                        padlockFilter.month.value = month;
                                        await mm.updatePadlocks(filter:padlockFilter);
                                        playFilter.type.value = playType;
                                        playFilter.bet.value = _betController.text;
                                        playFilter.betGT.value = _betControllerGT.text;
                                        filtering = true;
                                        mm.updatePlays(filter:playFilter).then((value) {
                                          playModelOptions = value;
                                        });
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
                      content: const Text("¿Estás seguro de que quieres eliminar los usuarios seleccionados?, no podra recuperarlos"),
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
            ):IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: (){
                  refresh();
                }
            ),
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: getList(),
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
    mm.removePlay(model: element.play).then((v) {
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
        refresh();
      }
    });
  }
  List<Widget> getList(){
    List<Widget> list = [];
    if (loading){
      list.add(const LinearProgressIndicator());
    }
    list.add(
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(mm.selectedUser.username),
          subtitle: Text("${(mm.selectedUser.isSuperuser)? "Superusuario": (mm.selectedUser.isStaff)?"Admin": "Listero"}"),
        )
    );

    if (elements.isNotEmpty){
      list.add(
          const ListTile(
            leading: Text(""),
            title: Text('Jugadas'),
          )
      );
      list.add(
          ListTile(
            leading: Text(""),
            title: Text("Dinero recaudado: $totalBet\$",style:const TextStyle( fontSize: 30)),
            subtitle: Text("Desde: ${padlockFilter.creAtGt.value}\nHasta: ${padlockFilter.creAtLt.value}"),
          )
      );
    }else{
      list.add(
          ListTile(
            leading: Text(""),
            title: Text("Dinero recaudado: $totalBet\$",style:const TextStyle( fontSize: 30)),
            subtitle: Text("Desde: ${padlockFilter.creAtGt.value}\nHasta: ${padlockFilter.creAtLt.value}"),
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
                  filtering = true;
                  playFilter.padlock.value = _padlockId.text;
                  await mm.updatePadlocks(filter: padlockFilter);
                  mm.updatePlays(filter:playFilter).then((value) {
                    playModelOptions = value;
                  });
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
    for (var element in elements) {
      if (element.selected) {
        isSelectingElements = true;
      }
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PlayWidget(
            element: element,
            onTap: () {
              if (selectingElements) {
                setState(() {
                  element.selected = !element.selected;
                });
              }else{
                mm.padlock = element.play.padlock;
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
                element.selected = !element.selected;
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
    if (playModelOptions.hasMore){
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
                playModelOptions = await mm.updatePlays(filter: playFilter, loadMore: true,page: playModelOptions.page);
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
  bool selected;
  bool deleting = false;
  PlayElement({required this.play, this.selected = false});
}
class PlayWidget extends StatelessWidget {
  const PlayWidget({required this.element, required this.onTap, this.onLongPress, this.selectingElements = false});
  final PlayElement element;
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
              title: Text("Para el mes: ${element.play.padlock.month}"),
              subtitle: Text("Tipo de jugada: ${element.play.type?.name}"),
              trailing: Text("#${element.play.padlock.id.toString().padLeft(8, '0')}"),
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
                        //more than 50% of width makes circle
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
                        //more than 50% of width makes circle
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
                      child: Center(child: Text("${element.play.bet}\$")),
                    ),
                  ),
                ),

              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:  Text("Realizada: ${(element.play.createdAt == null)? "No se sabe": element.play.createdAt!.toLocal().toString().split(".")[0]}"),
            )

          ],
        ),
      )


    );
  }
}

