
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../../routes/route_generator.dart';
import '../views.dart';

class AddCollectorPage extends StatefulWidget {
  const AddCollectorPage({Key? key}) : super(key: key);

  @override
  State<AddCollectorPage> createState() => _AddCollectorPageState();
}

class _AddCollectorPageState extends State<AddCollectorPage> {
  bool loading = true;

  late ModelsManager mm;
  ModelOptions collectorModelOptions = ModelOptions(hasMore: false, page: 1);

  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
    });
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();

    loading = (mm.status == ModelsStatus.updating);

    return Scaffold(
        appBar: AppBar(
          title: Text("Añadir colector"),
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
    }else {
      list.add(
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                    enabled: !loading,
                    validator: (val) {
                      if (val == null || val == "") {
                        return "Campo obligatorio";
                      }
                    },
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nombre",
                      hintText: "Nombre del colector",
                      icon: Icon(Icons.person),
                    )
                ),
                Container(height: 16),
                ElevatedButton.icon(
                  icon: (loading) ? CircularProgressIndicator() : Container(),
                  autofocus: true,
                  onPressed: (!loading) ? () async {
                    if (_formKey.currentState!.validate()) {
                      mm.createCollector(model: Collector(id: 0,name: _nameController.text, listers: [])).then((value){
                        showDialog(context: context, builder: (c){
                          return AlertDialog(
                            title: Text("colector ${_nameController.text} añadido correctamente"),
                            actions: [
                              OutlinedButton(
                                  onPressed: (){
                                    mm.updateCollectors();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("VOLVER")
                              ),
                              OutlinedButton(
                                  onPressed: (){
                                    mm.updateCollectors();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("ACEPTAR")
                              )
                            ],
                          );
                        });
                        _nameController..text = "";

                      });
                    }
                  } : null,
                  label: Text("AÑADIR"),
                ),

              ],
            ),
          ),
        ),
      );
    }
    return list;
  }

}