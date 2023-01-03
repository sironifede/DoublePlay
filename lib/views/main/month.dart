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
    return Scaffold(
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



    DateTime now = DateTime.now();
    List<int> monthsAdd = [];
    for (int i = 0 ;i<3;i++){
      int month = now.month;
      month += i;
      if (month > 12){
        month -= 12;
      }
      monthsAdd.add(month);
    }

    for (var month in mm.months){
      if(monthsAdd.contains(month.id) || month.enabled) {
        list.add(
            Center(
              child: ElevatedButton(
                child: Text("${months[month.id - 1]}"),
                onPressed: () async {
                  mm.newPlay = true;
                  mm.selectedPadlock = Padlock(
                      user: mm.user.id,
                      playing: true,
                      month: month.id,
                      moneyGenerated: 0,
                      selled: false,
                      listerMoneyCollected: false,
                      collectorMoneyCollected: false,
                      name: "",
                      phone: ""
                  );
                  print(mm.selectedPadlock!.toUpdateMap());
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
                },
              ),
            )
        );
      }
    }


    return list;
  }
}

