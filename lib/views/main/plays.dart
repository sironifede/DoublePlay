import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../filters/play.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';

class PlaysPage extends StatefulWidget {
  const PlaysPage({Key? key}) : super(key: key);

  @override
  State<PlaysPage> createState() => _PlaysPageState();
}

class _PlaysPageState extends State<PlaysPage> {

  bool loading = true;
  bool filtering = false;
  bool addingModels = false;
  late ModelsManager mm;
  User user = User();
  ModelOptions playModelOptions = ModelOptions(hasMore: false, page: 1);

  bool selectingElements = false;
  List<PlayElement> elements = [];

  List<String> months = <String>['', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  String month = '';
  List<String> playTypes = <String>['', 'JS', 'JSA', 'JD', 'JDA'];
  String playType = '';
  PlayFilter playFilter = PlayFilter();
  TextEditingController _dayController = TextEditingController();
  TextEditingController _nightController = TextEditingController();
  TextEditingController _dayControllerGT = TextEditingController();
  TextEditingController _nightControllerGT = TextEditingController();
  TextEditingController _betController = TextEditingController();
  TextEditingController _betControllerGT = TextEditingController();

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      user = mm.selectedUser!;
      playFilter.user.value = user.id!.toString();
      playModelOptions = await mm.updatePlays(filter: playFilter);
    });
  }
  void refresh() async {
    playModelOptions = await mm.updatePlays(filter: playFilter);
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);

    elements = [];
    for (var play in mm.plays) {
      elements.add(PlayElement(play: play));
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
          title: Text("Administrar usuario"),
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
                                title: Text("Filtros"),
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text("Mes de la jugada: ")),
                                        DropdownButton<String>(
                                          value: month,
                                          onChanged: (String? value) {
                                            print("cambio");
                                            // This is called when the user selects an item.
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
                                        Expanded(child: Text("Tipo de jugada:")),
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
                                    TextField(
                                      controller: _dayController,
                                      decoration: InputDecoration(
                                        labelText: playFilter.dayNumber.getLabelText,
                                        hintText: playFilter.dayNumber.getHintText,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ], // Only numbers can be entered
                                    ),
                                    TextField(
                                      controller: _dayControllerGT,
                                      decoration: InputDecoration(
                                        labelText: playFilter.dayNumberGT.getLabelText,
                                        hintText: playFilter.dayNumberGT.getHintText,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ], // Only numbers can be entered
                                    ),
                                    TextField(
                                      controller: _nightController,
                                      decoration: InputDecoration(
                                        labelText: playFilter.nightNumber.getLabelText,
                                        hintText: playFilter.nightNumber.getHintText,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ], // Only numbers can be entered
                                    ),
                                    TextField(
                                      controller: _nightControllerGT,
                                      decoration: InputDecoration(
                                        labelText: playFilter.nightNumberGT.getLabelText,
                                        hintText: playFilter.nightNumberGT.getHintText,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ], // Only numbers can be entered
                                    ),
                                    TextField(
                                      controller: _betController,
                                      decoration: InputDecoration(
                                        labelText: playFilter.bet.getLabelText,
                                        hintText: playFilter.bet.getHintText,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ], // Only numbers can be entered
                                    ),
                                    TextField(
                                      controller: _betControllerGT,
                                      decoration: InputDecoration(
                                        labelText: playFilter.betGT.getLabelText,
                                        hintText: playFilter.betGT.getHintText,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ], // Only numbers can be entered
                                    ),
                                    TimePickerDialog(initialTime: TimeOfDay.now())
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child:Text("CANCELAR"),
                                    onPressed: (){

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                      onPressed: () async {
                                        playFilter.month.value = month;
                                        playFilter.type.value = playType;
                                        playFilter.dayNumber.value = _dayController.text;
                                        playFilter.dayNumberGT.value = _dayControllerGT.text;
                                        playFilter.nightNumber.value = _nightController.text;
                                        playFilter.nightNumberGT.value = _nightControllerGT.text;
                                        playFilter.bet.value = _betController.text;
                                        playFilter.betGT.value = _betControllerGT.text;
                                        filtering = true;
                                        mm.updatePlays(filter:playFilter).then((value) {
                                          playModelOptions = value;

                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("FILTRAR")
                                  )
                                ],
                              );
                            }
                        );
                      }
                  );
                }
            ),
            /*(selectingElements)?IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  bool? result = await showDialog(context: context, builder: (_){
                    return AlertDialog(
                      title: Text("¿Eliminar los usuarios seleccionados?"),
                      content: Text("¿Estás seguro de que quieres eliminar los usuarios seleccionados?, no podra recuperarlos"),
                      actions: [
                        TextButton(
                          child:Text("CANCELAR"),
                          onPressed: (){
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child:Text("ACEPTAR"),
                          onPressed: (){
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],

                    );
                  });
                  if (result != null){
                    if (result){
                      int cant = 0;
                      print("eliminando usuarios");//TODO implements eliminar usuarios


                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Se han elimnado $cant usuarios")),
                      );
                      setState(() {
                        selectingElements = false;
                      });
                    }
                  }
                }
            ):*/IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: (){
                  refresh();
                }
            ),
            /*PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {"Seleccionar todo",}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),*/
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
  List<Widget> getList(){
    List<Widget> list = [];
    if (loading){
      list.add(const LinearProgressIndicator());
    }
    list.add(
        ListTile(
          leading: Icon(Icons.person),
          title: Text(user.username),
          subtitle: Text("${(user.isSuperuser)? "Superusuario": (user.isStaff)?"Admin": "Listero"}"),
        )
    );

    if (elements.isNotEmpty){
      list.add(
          ListTile(
            leading: const Text(""),
            title: Text('Jugadas',style: TextStyle(color: Theme.of(context).primaryColor),),
          )
      );
    }else{
      list.add(
          ListTile(
            leading: const Text(""),
            title: Text('No hay Jugadas',style: TextStyle(color: Theme.of(context).primaryColor),),
          )
      );
      list.add(
          Center(
              child:Icon(Icons.warning)
          )
      );
    }
    if (filtering){
      list.add(
          ListTile(
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
            play: element.play,
            onTap: () {
              if (selectingElements) {
                setState(() {
                  element.selected = !element.selected;
                });
              } else {
              }
            },
            onLongPress: () {
              if (!selectingElements) {
                setState(() {
                  selectingElements = true;
                });
              }
              setState(() {
                element.selected = !element.selected;
              });
            },
            selected: element.selected,
            selectingElements: selectingElements,
          ),
        ),
      );

    }
    if (playModelOptions.hasMore){
      if (addingModels){
        list.add(
          Center(
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
    if (!isSelectingElements && selectingElements){
      Future.delayed(Duration(milliseconds: 1),(){
        setState(() {
          selectingElements = false;
        });
      });
    }


    list.add(const Divider());
    list.add(
        ListTile(
            leading:Icon(Icons.info_outline),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    children: [
                      Text("-Toca en "),
                      Icon(Icons.filter_alt),
                      Text(" para filtrar las jugadas")
                    ]
                ),
                Row(
                  children: [
                    Text("-Este circulo "),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(60)
                        //more than 50% of width makes circle
                      ),
                      child: Text(""),
                    ),
                    Text(" es el numero de dia")
                  ],
                ),
                Row(
                  children: [
                    Text("-Este circulo "),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(60)
                        //more than 50% of width makes circle
                      ),
                      child: Text(""),
                    ),
                    Text(" es el numero de noche")
                  ],
                ),
                Row(
                  children: [
                    Text("-Este circulo "),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(60)
                        //more than 50% of width makes circle
                      ),
                      child: Center(child: Text("\$")),
                    ),
                    Text(" es el dinero de la apuesta")
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
  PlayElement({required this.play, this.selected = false});
}
class PlayWidget extends StatelessWidget {
  const PlayWidget({required this.play, required this.onTap, this.onLongPress, this.selected = false, this.selectingElements = false});
  final Play play;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final bool selected;
  final bool selectingElements;
  @override
  Widget build(BuildContext context){
    return Card(
      child: Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        children: [
          ListTile(
              title: Text("Para el mes: ${play.month}"),
            subtitle: Text("Tipo de jugada: ${play.type.name}"),
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(60)
                      //more than 50% of width makes circle
                    ),
                    child: Center(child: Text("${play.dayNumber}")),
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
                    child: Center(child: Text("${play.nightNumber}")),
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
                    child: Center(child: Text("${play.bet}\$")),
                  ),
                ),
              ),

            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:  Text("Realizada: ${(play.createdAt == null)? "No se sabe": play.createdAt!.toLocal().toString().split(".")[0]}"),
          )

        ],
      )

      /*onLongPress: onLongPress,
      onTap: onTap,*/
    );
  }
}

