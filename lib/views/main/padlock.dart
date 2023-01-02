import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../filters/play.dart';
import '../../models/models.dart';
import '../shimmer.dart';

class PadlockPage extends StatefulWidget {
  const PadlockPage({Key? key,}): super(key: key);
  @override
  _PadlockPageState createState() => _PadlockPageState();
}

class _PadlockPageState extends State<PadlockPage> {
  bool loading = false;
  bool navigate = false;
  late ModelsManager mm;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();


  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      _refresh();
    });
  }
  Future<void> _refresh() async {
    mm.updateModels(modelType: ModelType.play,filter: PlayFilter(padlocks: [mm.selectedPadlock!.id]));
    setState(() {

      _nameController..text = mm.selectedPadlock!.name;
      _phoneController..text = mm.selectedPadlock!.phone;
    });
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    if (navigate){
      navigate = false;
      Future.delayed(Duration(milliseconds: 1),() async {
        Navigator.of(context).pushNamed(Routes.generateTicket);
      });
    }
    loading = (mm.status == ModelsStatus.updating);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Candados"),
      ),
      body:RefreshIndicator(
        onRefresh: _refresh,
        child: Shimmer(
          child: ShimmerLoading(
            isLoading: loading,
            child: ListView(
                children: generateColumn()
            ),
          ),
        ),
      ),
    );
  }
  List<Widget> generateColumn(){
    List<Widget> list = [];

    list.add(
        ListTile(
            title: Text("Candados separados para generar el ticket de las jugadas:")
        )
    );
    List<Widget> plays = [];
    for (var play in mm.plays){
      if (play.padlock == mm.selectedPadlock!.id) {
        plays.add(
            Center(
              child: PlayListTile(
                  play: play,
                  onTap: () {

                  }
              ),
            )
        );
      }
    }
    list.add(
      Padding(
        padding: const EdgeInsets.only(left:64, right: 64, top: 8),
        child: Column(
          children:plays,
        ),
      )
    );
    list.add(Divider());
    list.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Nombre",
            hintText: "Nombre del jugador",
          ),
        ),
      ),
    );
    list.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: "Telefono",
            hintText: "Telefono del jugador",
          ),
        ),
      ),
    );
    list.add(Divider());
    list.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: (){
                    mm.selectedPadlock!.name = _nameController.text;
                    mm.selectedPadlock!.phone = _phoneController.text;
                    mm.updateModel(modelType: ModelType.padlock,model: mm.selectedPadlock!).then((value) {
                      setState(() {
                        navigate = true;
                      });
                    });
                  },
                  child: Text("GENERAR TICKET")
              ),
            ),
          ],
        )
    );
    list.add(
      SizedBox(
        height: 100,
      )
    );


    return list;
  }
}

class PlayListTile extends StatelessWidget {
  const PlayListTile({required this.play, required this.onTap, this.onLongPress, this.selected = false, this.selectingElements = false});
  final Play play;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final bool selected;
  final bool selectingElements;
  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(5),
      color: Colors.black,
      child: Container(
          padding: const EdgeInsets.all(10),
        color: Colors.amber,
          child: Column(
            children: [
              Text("${play.dayNumber.toString().padLeft(3, '0')}-${play.nightNumber.toString().padLeft(3, '0')}", style: TextStyle(fontSize: 40)),
              Text("${play.type?.name} - \$${play.bet}")
            ],
          )
        /*onLongPress: onLongPress,
        onTap: onTap,*/
      ),
    );
  }
}



