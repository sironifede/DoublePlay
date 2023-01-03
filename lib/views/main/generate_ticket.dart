import 'package:bolita_cubana/filters/filters.dart';
import 'package:bolita_cubana/models/model.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/collector.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../../models/play.dart';
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
    //await mm.fetchUser();
    await mm.updateModels(modelType: ModelType.play, filter: PlayFilter(padlocks: [mm.selectedPadlock!.id]));
    await mm.updateModels(modelType: ModelType.collector);

    List<int> newList = [];
    for (var collector in mm.collectors){
      if (collector.listers.contains(mm.selectedPadlock!.user)){
        newList.add(mm.selectedPadlock!.user);
        newList.add(collector.user);
        print(newList);
        break;
      }
    }

    mm.updateModels(modelType: ModelType.user,newList: newList, filter: UserFilter());

  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: (){
                Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
              },
              icon: Icon(Icons.home),
            ),
          ],
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
                  SizedBox(
                    height: 100,
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];
    Collector? collector;
    User? user;
    User? userCollector;
    for (var i in mm.collectors){

      if (i.listers.contains(mm.selectedPadlock?.user)){
        collector = i;
        break;
      }
    }
    for (var i in mm.users){

      if (i.id == mm.selectedPadlock?.user){
        user = i;
      }
      if (i.id == collector?.user){
        userCollector = i;
      }

    }
    list.add(Text("CT#${(collector == null)? "no tiene": userCollector?.username} LT#${user?.username}",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w800,color: Colors.black)));
    list.add(Text("MES:${months[mm.selectedPadlock!.month - 1]}",style: TextStyle(fontSize: 20, color: Colors.black),));
    list.add(Text("${DateFormat('yyyy-MMMM-dd hh:mm a').format(mm.selectedPadlock!.updatedAt!.toLocal())}",style: TextStyle( color: Colors.black)));
    list.add(
        SizedBox(
          height: 32,
        )
    );
    int total = 0;
    for (var play in mm.plays) {
      if (play.padlock == mm.selectedPadlock!.id) {
        list.add(
            Row(
              children: [
                Text("${play.dayNumber.toString().padLeft(3, '0')}-${play
                    .nightNumber.toString().padLeft(3, '0')} ${play.type
                    ?.name}",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                Expanded(child: Text("")),
                Text("\$${play.bet}",
                    style: TextStyle(fontSize: 20, color: Colors.black))
              ],
            )
        );

        if ([PlayType.JD, PlayType.JDA].contains(play.type)) {
          list.add(
              Row(
                children: [
                  Text("${play.nightNumber.toString().padLeft(3, '0')}-${play
                      .dayNumber.toString().padLeft(3, '0')} ${play.type
                      ?.name}",
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                ],
              )
          );
        }
        total += play.bet;
      }
    }
    list.add(
        SizedBox(
          height: 32,
        )
    );
    list.add(
        Row(
          children: [
            Text("TOTAL: ",style: TextStyle(fontSize: 20, color: Colors.black)),
            Expanded(child:Text("")),
            Text("\$${total}",style: TextStyle(fontSize: 20, color: Colors.black))
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
            Text("${mm.selectedPadlock!.id.toString().padLeft(8, '0')}",style: TextStyle(fontSize: 20, color: Colors.black)),
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
            Text("Info",style: TextStyle(fontSize: 20, color: Colors.black)),
          ],
        )
    );
    list.add(
        Row(
          children: [
            Text("Telefono: ${mm.selectedPadlock!.phone}",style: TextStyle(fontSize: 20, color: Colors.black)),
          ],
        )
    );
    list.add(
        Row(
          children: [
            Text("Nombre: ${mm.selectedPadlock!.name}",style: TextStyle(fontSize: 20, color: Colors.black)),
          ],
        )
    );
    list.add(
      TextButton.icon(
          icon: Icon(Icons.telegram),
          onPressed: () async {
            const url = 'https://t.me/s/CDCDOUBLEPLAY1MILLION';
            try{
              await launch(url);
            }catch(e) {
              print(e);
            }
          },
          label: Text("CDCDOUBLEPLAY1MILLION")
      ),

    );
    list.add(
      TextButton.icon(
          icon: Icon(Icons.telegram),
          onPressed: () async {
            const url = 'https://t.me/Bolita1deCuba';
            try{
              await launch(url);
            }catch(e) {
              print(e);
            }
          },
          label: Text("Bolita1deCuba")
      ),
    );

    return list;
  }
}
