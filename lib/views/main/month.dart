import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({Key? key,}): super(key: key);
  @override
  _MonthPageState createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  bool loading = false;
  bool navigate = false;
  late ModelsManager mm;


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();

  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    if (navigate){
      navigate = false;
      Future.delayed(Duration(milliseconds: 1),() async {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.play, (Route<dynamic> route) => false);
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Elegir mes"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.settings);
              },
            ),
          ],
        ),
        body:Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            children:generateColumn()
        )
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];
    if (mm.status == ModelsStatus.updating ){
      list.add(LinearProgressIndicator());
    }else {
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
            index += now.month ;
            if (now.month > 8) {
              if (index > 11) {
                index -= 12;
              }
            }

            return Center(
              child: ElevatedButton(
                child: Text("${months[index]}"),
                onPressed: () async {
                  await mm.createPadlock(model: Padlock(user: mm.user, playing: true, month: index + 1)).then((value) {
                    mm.firstPlay = true;
                    navigate = true;
                  });

                },
              ),
            );
          },
        ),
      );
    }
    return list;
  }
}

