import 'package:bolita_cubana/filters/filters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models_manager.dart';
import '../../routes/route_generator.dart';
import '../shimmer.dart';


class GenerateTicket extends StatefulWidget {
  const GenerateTicket({Key? key,}): super(key: key);
  @override
  _GenerateTicketState createState() => _GenerateTicketState();
}

class _GenerateTicketState extends State<GenerateTicket> {
  bool loading = false;
  late ModelsManager mm;
  List<String> months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre" ];


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      await _refresh();
    });
  }
  Future<void> _refresh() async {
    await mm.fetchUser();
    mm.updatePlays(filter:PlayFilter(padlock: mm.padlock.id.toString()));
    mm.updateCollectors();
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ticket"),
      ),
      body:RefreshIndicator(
        onRefresh: _refresh,
        child: Shimmer(
          child: ShimmerLoading(
            isLoading: loading,
            child: ListView(
                children:[
                  ListTile(
                      title: Text("Para reclamar su premio")
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height - 200,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color:Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: generateColumn(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            mm.showContinuePlayingDialog = false;
            Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);
          },
          label: Text("VOLVER AL INICIO")
      ),
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];

    for (var i in mm.collectors){
      if (i.listers.contains(mm.padlock.user.id)){
        list.add(Text("CT#${i.id} LT#${mm.padlock.user.id}",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w800,color: Colors.black)));
        list.add(Text("MES:${months[mm.padlock.month - 1]}",style: TextStyle(fontSize: 20, color: Colors.black),));
        list.add(Text("${mm.padlock.createdAt!.month}/${mm.padlock.createdAt!.day}/${mm.padlock.createdAt!.year}",style: TextStyle( color: Colors.black)));
        list.add(
            SizedBox(
              height: 32,
            )
        );
        int total = 0;
        for (var play in mm.plays){
          print("haasdfkljasdflkasdjf");
          list.add(
              Row(
                children: [
                  Text("${play.dayNumber.toString().padLeft(3, '0')}-${play.nightNumber.toString().padLeft(3, '0')} ${play.type?.name}  -  ${play.bet}\$",style: TextStyle(fontSize: 20, color: Colors.black)),
                ],
              )
          );
          total += play.bet;
        }
        list.add(
            SizedBox(
              height: 32,
            )
        );
        list.add(
            Row(
              children: [
                Text("TOTAL: ${total}\$",style: TextStyle(fontSize: 20, color: Colors.black)),
              ],
            )
        );
        list.add(
            SizedBox(
              height: 32,
            )
        );
        list.add(
            SizedBox(
              child: Row(
                children: [
                  Text("Numero de confirmacion",style: TextStyle(fontSize: 20,color: Colors.black)),
                ],
              ),
            )
        );
        list.add(
            Row(
              children: [
                Text("${mm.padlock.id.toString().padLeft(8, '0')}",style: TextStyle(fontSize: 20, color: Colors.black)),
              ],
            )
        );
        list.add(
            SizedBox(
              height: 32,
            )
        );
        list.add(
            Row(
              children: [
                Text("Info Opcional",style: TextStyle(fontSize: 20, color: Colors.black)),
              ],
            )
        );
        list.add(
            Row(
              children: [
                Text("Telefono: ${mm.padlock.phone}",style: TextStyle(fontSize: 20, color: Colors.black)),
              ],
            )
        );
        list.add(
            Row(
              children: [
                Text("Nombre: ${mm.padlock.name}",style: TextStyle(fontSize: 20, color: Colors.black)),
              ],
            )
        );
        break;
      }
    }



    return list;
  }
}
