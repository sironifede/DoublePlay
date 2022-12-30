import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../shimmer.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({Key? key,}): super(key: key);
  @override
  _MonthPageState createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  bool loading = false;
  bool navigate = false;
  late ModelsManager mm;
  bool hasError = false;

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      await _refresh();
    });
  }
  Future<void> _refresh() async {
    ModelOptions options = await mm.updateModels(modelType: ModelType.month);
    if (hasError != options.hasError){
      setState(() {
        hasError = options.hasError;
      });
    }
    await mm.updateModels(filter:PadlockFilter(playing: true), modelType: ModelType.padlock);
    for (var model in mm.padlocks){
      if (model.user == mm.user.id){
        if (model.playing){
          mm.selectedPadlock = model;
          Future.delayed(Duration(milliseconds: 1), () {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    icon: const Icon(Icons.warning),
                    title: Text("Ya estabas jugando"),
                    content: Text(
                        "Nunca terminaste tu anterior jugada, puedes volver a donde te habias quedado o descartarla."),
                    actions: [
                      TextButton(
                        child: Text("DESCARTAR"),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      TextButton(
                        child: Text("SEGUIR JUGANDO"),
                        onPressed: () async {
                          mm.newPlay = false;
                          await mm.updateModels(modelType: ModelType.play, filter:PlayFilter( padlocks: [mm.selectedPadlock!.id]));
                          for (var play in mm.plays){
                            if (play.padlock == mm.selectedPadlock!.id){
                              if (!play.confirmed){
                                mm.selectedPlay = play;
                              }else{
                                mm.selectedPlay = Play(
                                    id: 0,
                                    padlock: 0,
                                    bet: 5,
                                    confirmed: false,
                                    dayNumber: 1,
                                    nightNumber: 1,
                                    nRandom: 0,
                                    type: PlayType.JS
                                );
                              }
                            }
                          }
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  );
                }).then((value) {
              if (value != null){
                if (value){
                  mm.removeModel(modelType:ModelType.padlock,model: mm.selectedPadlock!);
                }else{
                  Navigator.of(context).pushNamed(Routes.play);
                }
              }else{
                mm.removeModel(modelType:ModelType.padlock,model: mm.selectedPadlock!);
              }
            });
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);
    if (hasError){
      Future.delayed(Duration(milliseconds: 1),(){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Hubo un error!!!")),
        );
      });
      hasError = false;

    }
    return CustomScaffold(
        appBar: AppBar(
          title: const Text("Elegir mes"),
        ),
        body:RefreshIndicator(
          onRefresh: _refresh,
          child: Shimmer(
            child: ShimmerLoading(
              isLoading: loading,
              child: ListView(
                  children:generateColumn()
              ),
            ),
          ),
        )
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];
    list.add(
        ListTile(
          title: Text('Escoja el mes de su jugada'),
        )
    );
    list.add(Divider());
    List<String> months = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];
    list.add(
      ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          DateTime now = DateTime.now();
          index += now.month -1;
          if (now.month - 1 > 8) {
            if (index > 11) {
              index -= 12;
            }
          }

          return Center(
            child: ElevatedButton(
              child: Text("${months[index]}"),
              onPressed: (mm.months[index].enabled)? () async {
                mm.newPlay = true;
                mm.selectedPadlock = Padlock(
                  user: mm.user.id,
                  playing: true,
                  month: mm.months[index].id,
                  moneyGenerated: 0,
                  selled: false,
                  listerMoneyCollected: false,
                  collectorMoneyCollected: false,
                  name: "",
                  phone: ""
                );
                mm.selectedPlay = Play(
                  id: 0,
                  padlock: 0,
                  bet: 5,
                  confirmed: false,
                  dayNumber: 1,
                  nightNumber: 1,
                  nRandom: 0,
                  type: PlayType.JS
                );
                Navigator.of(context).pushNamed(Routes.play);
              }:null,
            ),
          );
        },
      ),
    );

    return list;
  }
}

