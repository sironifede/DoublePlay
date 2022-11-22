import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/models_manager.dart';

class DisabledBetsPage extends StatefulWidget {
  const DisabledBetsPage({Key? key,}): super(key: key);
  @override
  _DisabledBetsPageState createState() => _DisabledBetsPageState();
}

class _DisabledBetsPageState extends State<DisabledBetsPage> {
  bool loading = false;
  late ModelsManager mm;
  List<int> betNumbers = [];
  int month = 0;
  List<String> months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ];


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      await mm.updateDisabledBets();
      updateNumbers();
    });
  }
  void updateNumbers(){
    for (var i in mm.disabledBets){
      if (month + 1 == i.month){
        Future.delayed(Duration(milliseconds: 1),(){
          setState(() {
            betNumbers = i.betNumbers;
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

                    await mm.updateDisabledBets();
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
          title: const Text("Apuestas dehabilitados"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: generateBetColumn(),
          ),
        ),

      ),
    );
  }
  List<Widget> generateBetColumn(){
    List<Widget> list = [];
    if (mm.status == ModelsStatus.updating ){
      list.add(LinearProgressIndicator());
    }else {

      List<Widget> numbers = [];
      List prices = [5, 10, 15, 20, 25, 30, 40, 50, 100, 200, 300];
      
      for (var i in prices){
        numbers.add(
            OutlinedButton(
                onPressed: () {
                  if (betNumbers.contains(i)){
                    setState(() {
                      betNumbers.remove(i);
                    });

                  }else{
                    setState(() {
                      betNumbers.add(i);
                    });

                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: (betNumbers.contains(i))?Colors.green: Colors.black,
                  minimumSize: Size.zero, // Set this
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                child: Text("${i}\$",
                  style: TextStyle(color: Colors.white),
                )
            )
        );

      }
      list.add(
          Wrap(
            spacing: 0,
            children: numbers,
            alignment: WrapAlignment.spaceBetween,
          )
      );
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
                      mm.disabledBets[month].betNumbers = betNumbers;
                      mm.updateDisabledBet(model: mm.disabledBets[month]).then((value) {
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