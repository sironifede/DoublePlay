
import 'package:bolita_cubana/models/models.dart';
import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/views/main/padlock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../filters/play.dart';
import '../../models/models_manager.dart';
import '../../models/play.dart';

class DisabledNumbersPage extends StatefulWidget {
  const DisabledNumbersPage({Key? key,}): super(key: key);
  @override
  _DisabledNumbersPageState createState() => _DisabledNumbersPageState();
}

class _DisabledNumbersPageState extends State<DisabledNumbersPage> {
  bool loading = false;
  late ModelsManager mm;
  List<int> dayNumbers = [];
  List<int> nightNumbers = [];
  int month = 0;
  List<String> months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ];


  TextEditingController _dayController = TextEditingController();
  TextEditingController _nightController = TextEditingController();

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      await mm.updateDisabledNumbers();
      updateNumbers();
    });
  }
void updateNumbers(){
  for (var i in mm.disabledNumbers){
    if (month + 1 == i.month){
      Future.delayed(Duration(milliseconds: 1),(){
        setState(() {
          dayNumbers = i.dayNumbers;
          nightNumbers = i.nightNumbers;
        });
      });
      break;
    }
  }
}
  @override
  Widget build(BuildContext context) {

    mm = context.watch<ModelsManager>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              DropdownButton<String>(
                value: months[month],
                onChanged: (String? value) async {
                  // This is called when the user selects an item.

                  for (int i = 0; i < months.length; i++) {
                    if (months[i] == value) {

                      month = i;

                      await mm.updateDisabledNumbers();
                      updateNumbers();
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
            title: const Text("Numeros dehabilitados"),
            bottom: TabBar(
              tabs: [
                Tab(icon: Center(child: Image.asset('assets/images/sun.png')),),
                Tab(icon: Center(child: Image.asset('assets/images/moon.png')),),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: generateDayColumn(),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: generateNightColumn(),
                ),
              ),
            ],
          ),

      ),
    );
  }
  List<Widget> generateNightColumn() {
    List<Widget> list = [];
    if (mm.status == ModelsStatus.updating) {
      list.add(LinearProgressIndicator());
    } else {
      list.add(
          ListTile(
              title: Text("numeros dehabilitados")
          )
      );
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            enabled: !loading,
            controller: _nightController,
            decoration: InputDecoration(
                labelText: "Añadir numero",
                hintText: "Para añadir numero",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    try {
                      if (!nightNumbers.contains(int.parse(_nightController.text))) {
                        if (int.parse(_nightController.text) > 0 && int.parse(_nightController.text) < 1000) {
                          setState(() {
                            nightNumbers.add(int.parse(_nightController.text));
                            _nightController..text = "";
                          });
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("No se puede dehabilitar ese numero")),
                          );
                        }

                      }
                    } catch (e) {}
                  },
                )
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
        ),
      );
      List<Widget> numbers = [];

      for (var i = 1; i < 1000; i++) {
        if (nightNumbers.contains(i)) {
          numbers.add(
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      nightNumbers.remove(i);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size.zero, // Set this
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: Text("${i.toString().padLeft(3, '0')}",
                    style: TextStyle(color: Colors.white),
                  )
              )
          );
        }
      }
      if (numbers.isNotEmpty) {
        list.add(
            Wrap(
              spacing: 0,
              children: numbers,
              alignment: WrapAlignment.spaceBetween,
            )
        );
      } else {
        list.add(
            ListTile(
                leading: Icon(Icons.warning),
                title: Text("Todavia no se deshabiltaron numeros")
            )
        );
      }
      list.add(Divider());
      list.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Text(""),),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      mm.disabledNumbers[month].nightNumbers = nightNumbers;
                      mm.updateDisabledNumber(
                          model: mm.disabledNumbers[month]).then((
                          value) {
                        updateNumbers();
                      });
                    },
                    child: Text("GUARDAR")
                ),
              ),
            ],
          )
      );
    }
    return list;
  }
  List<Widget> generateDayColumn(){
    List<Widget> list = [];
    if (mm.status == ModelsStatus.updating ){
      list.add(LinearProgressIndicator());
    }else {
      list.add(
          ListTile(
              title: Text("numeros dehabilitados")
          )
      );
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              enabled: !loading,
              controller: _dayController,
              decoration: InputDecoration(
                  labelText: "Añadir numero",
                  hintText: "Para añadir numero",
                  suffixIcon:  IconButton(
                    icon: Icon( Icons.add),
                    onPressed: (){
                      try{
                        if (!dayNumbers.contains(int.parse(_dayController.text))){
                          if (int.parse(_dayController.text) > 0 && int.parse(_dayController.text) < 1000) {
                            setState(() {
                              dayNumbers.add(int.parse(_dayController.text));
                              _dayController..text = "";
                            });
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("No se puede dehabilitar ese numero")),
                            );
                          }
                        }
                      }catch(e){}

                    },
                  )
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
          ),
        ),
      );
      List<Widget> numbers = [];

      for (var i= 1;i<1000; i++){
        if (dayNumbers.contains(i)) {
          numbers.add(
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      dayNumbers.remove(i);
                    });

                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size.zero, // Set this
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: Text("${i.toString().padLeft(3, '0')}",
                    style: TextStyle(color: Colors.white),
                  )
              )
          );
        }
      }
      if (numbers.isNotEmpty) {
        list.add(
            Wrap(
              spacing: 0,
              children: numbers,
              alignment: WrapAlignment.spaceBetween,
            )
        );
      }else{
        list.add(
            ListTile(
              leading: Icon(Icons.warning),
              title: Text("Todavia no se deshabiltaron numeros")
            )
        );
      }
      list.add(Divider());
      list.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Text(""),),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: (){
                      mm.disabledNumbers[month].dayNumbers = dayNumbers;
                      mm.updateDisabledNumber(model: mm.disabledNumbers[month]).then((value) {
                        updateNumbers();
                      });
                    },
                    child: Text("GUARDAR")
                ),
              ),
            ],
          )
      );
    }

    return list;
  }
}