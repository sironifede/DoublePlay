import 'package:bolita_cubana/models/models.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/model.dart';
import '../../models/models_manager.dart';
import '../shimmer.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool loading = true;
  bool filtering = false;
  bool addingModels = false;
  bool selectingElements = false;
  List<HelpElement> elements = [];
  late ModelsManager mm;

  void handleClick(String value) async {
    switch (value) {
      case "Seleccionar todo":
        setState(() {
          selectingElements = true;
          bool selectAll = false;
          for (var element in elements){
            if (!element.selected){
              selectAll = true;
            }
          }
          for (var element in elements){
            element.selected = selectAll;
          }
        });
        break;
      case "":
        break;

    }
  }
  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async {
      _refresh();
    });
  }
  Future<void> _refresh() async {
    await mm.updateModels(modelType: ModelType.help);
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    if (!selectingElements){
      elements = [];
      for (var help in mm.helps) {
        elements.add(HelpElement(help: help));
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Ayuda"),
          actions: <Widget>[
            (selectingElements)?IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  bool? result = await showDialog(context: context, builder: (_){
                    return AlertDialog(
                      title: Text("¿Eliminar los usuarios seleccionados?"),
                      content: Text("¿Estás seguro de que quieres eliminar los usuarios seleccionados?, no podra recuperarlos"),
                      actions: [
                        TextButton(
                          child:Text("CANCELAR"),
                          onPressed: (){
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child:Text("ACEPTAR"),
                          onPressed: (){
                            Navigator.of(context).pop(true);
                          },
                        )
                      ],

                    );
                  });
                  if (result != null){
                    if (result){
                      print("eliminando usuarios");
                      removeElement(1);
                    }
                  }
                }
            ):Text(""),
            (mm.user.isStaff || mm.user.isSuperuser)? PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {"Seleccionar todo",}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ): Text(""),
          ],
        ),
        body:
        RefreshIndicator(
          onRefresh: _refresh,
          child: Shimmer(
            child: ShimmerLoading(
              isLoading: (mm.status == ModelsStatus.updating),
              child: ListView(
                children: generateColumn(),
              )
            ),
          ),
        )
    );
  }
  void removeElement(int cant){
    var element;
    for (element in elements){
      if (element.selected){
        break;
      }
    }
    setState(() {
      element.deleting = true;
    });
    mm.removeModel(modelType:ModelType.help,model: element.help).then((v) {
      elements.remove(element);
      mm.helps.remove(element.user);
      bool continueDeleting = false;
      for (element in elements){
        if (element.selected){
          continueDeleting = true;
          break;
        }
      }
      if (continueDeleting) {
        print("continuar eliminando");
        cant = cant + 1;
        removeElement(cant);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Se han elimnado $cant ayudas")),
        );
        _refresh();
      }
    });
  }
  List<Widget> generateColumn() {
    List<Widget> list = [];
    bool isSelectingElements = false;
    for (var element in elements) {
      if (element.selected) {
        isSelectingElements = true;
      }
      if (list.isNotEmpty) {
        list.add(Divider());
      }
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: HelpWidget(
            element: element,
            onTap: () {
              if (selectingElements) {
                if (mm.user.isSuperuser || mm.user.isStaff){
                  setState(() {
                    element.selected = !element.selected;
                  });
                }
              }
            },
            onLongPress: (mm.user.isSuperuser || mm.user.isStaff)? () {
              if (!selectingElements) {
                setState(() {
                  selectingElements = true;
                });
              }
              setState(() {
                element.selected = !element.selected;
              });
            }:null ,
            selectingElements: selectingElements,
          ),
        ),
      );

    }

    if (!isSelectingElements && selectingElements){
      Future.delayed(Duration(milliseconds: 1),(){
        setState(() {
          selectingElements = false;
        });
      });
    }
    return list;
  }
}

class HelpElement{
  final Help help;
  bool selected;
  bool deleting = false;
  HelpElement({required this.help, this.selected = false});
}
class HelpWidget extends StatelessWidget {
  const HelpWidget({super.key, required this.element, required this.onTap, this.onLongPress, this.selectingElements = false});
  final HelpElement element;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final bool selectingElements;
  @override
  Widget build(BuildContext context){
    return ListTile(
      leading: (selectingElements)?Checkbox(value: element.selected, onChanged: (b){},) : null,
      selected: element.selected,
      onLongPress: onLongPress,
      trailing:(element.deleting)? CircularProgressIndicator(): null,
      title: ExpansionTile(
        title: Text("${element.help.question}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${element.help.answer}"),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}