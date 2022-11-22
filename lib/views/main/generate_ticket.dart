import 'package:bolita_cubana/filters/filters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models_manager.dart';


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
      await mm.fetchUser();
      mm.updateUsers().then((value) {
        mm.updatePadlocks();
      });
      mm.updateCollectors();
    });
  }

  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await mm.fetchUser();
                mm.updateUsers().then((value) {
                  mm.updatePadlocks();
                });
                mm.updateCollectors();
              },
            ),
          ],
          title: const Text("Ticket"),
        ),
        body:SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
        )
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];
    if (mm.status == ModelsStatus.updating ){
      list.add(LinearProgressIndicator());
    }else {
      for (var i in mm.collectors){
        for (var j in mm.padlocks){
          if (i.listers.contains(j.user.id) && j.id == mm.padlock.id){
            list.add(Text("CT#${i.id} LT#${j.user.id}",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w800),));
            list.add(Text("MES:${months[j.month - 1]}",style: TextStyle(fontSize: 20),));
            list.add(Text("${j.createdAt!.month}/${j.createdAt!.day}/${j.createdAt!.year}"));
            list.add(
                SizedBox(
                  height: 32,
                )
            );
            for (var play in mm.plays){
              if (play.padlock.id == j.id){
                list.add(
                    Row(
                      children: [
                        Text("${play.dayNumber.toString().padLeft(3, '0')}-${play.nightNumber.toString().padLeft(3, '0')} ${play.type?.name}",style: TextStyle(fontSize: 20)),
                      ],
                    )
                );
              }
            }
            list.add(
                SizedBox(
                  height: 32,
                )
            );
            list.add(
              SizedBox(
                child: Row(
                  children: [
                    Text("Numero de confirmacion",style: TextStyle(fontSize: 20)),
                  ],
                ),
              )
            );
            list.add(
              Row(
                children: [
                  Text("${j.id.toString().padLeft(8, '0')}",style: TextStyle(fontSize: 20)),
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
                    Text("Info Opcional",style: TextStyle(fontSize: 20)),
                  ],
                )
            );
            list.add(
                Row(
                  children: [
                    Text("Telefono: ${j.phone}",style: TextStyle(fontSize: 20)),
                  ],
                )
            );
            list.add(
                Row(
                  children: [
                    Text("Nombre: ${j.name}",style: TextStyle(fontSize: 20)),
                  ],
                )
            );
            break;
          }
        }
      }

    }

    return list;
  }
}
