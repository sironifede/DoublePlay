
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../../routes/route_generator.dart';
import '../shimmer.dart';
import '../views.dart';

class CollectorsPage extends StatefulWidget {
  const CollectorsPage({Key? key}) : super(key: key);

  @override
  State<CollectorsPage> createState() => _CollectorsPageState();
}

class _CollectorsPageState extends State<CollectorsPage> {
  bool loading = true;
  bool filtering = false;
  bool addingModels = false;
  bool selectingElements = false;
  bool selectingCollector = false;
  List<CollectorElement> elements = [];
  late ModelsManager mm;
  ModelOptions collectorModelOptions = ModelOptions(hasMore: false, page: 1);

  TextEditingController _nameController = TextEditingController();
  TextEditingController _listersController = TextEditingController();
  CollectorFilter collectorFilter = CollectorFilter();

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
      await mm.updateUsers();
      collectorModelOptions = await mm.updateCollectors(filter: collectorFilter);

    });
  }
  Future<void> _refresh() async {
    await mm.updateUsers();
    collectorModelOptions = await mm.updateCollectors(filter: collectorFilter);
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    bool updating = false;
    bool deleting = false;
    for (var element in elements){
      if (element.updating){
        updating = true;

      }
      if (element.deleting){
        deleting = true;
      }
    }
    if (!updating) {
      if (!selectingElements) {
        elements = [];
        for (var collector in mm.collectors) {
          elements.add(CollectorElement(collector: collector));
        }
      }
    }
    loading = (mm.status == ModelsStatus.updating);
    if (!loading) {
      if (filtering) {
        setState(() {
          filtering = false;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Administrar colectores"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: (){
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return StatefulBuilder(
                          builder: (context, StateSetter setState) {
                            return AlertDialog(
                              scrollable: true,
                              title: Text("Filtros"),
                              content: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: collectorFilter.name.getLabelText,
                                      hintText: collectorFilter.name.getHintText,
                                    ),
                                  ),
                                  TextField(
                                    controller: _listersController,
                                    decoration: InputDecoration(
                                      labelText: collectorFilter.listers.getLabelText,
                                      hintText: collectorFilter.listers.getHintText,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: Text("CANCELAR"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                    onPressed: () async {
                                      selectingElements = false;
                                      filtering = true;
                                      Navigator.of(context).pop();
                                      collectorFilter.name.value = _nameController.text;
                                      collectorFilter.listers.value = _listersController.text;
                                      collectorModelOptions = await mm.updateCollectors(filter: collectorFilter);

                                    },
                                    child: Text("FILTRAR")
                                )
                              ],
                            );
                          }
                      );
                    }
                );
              }
          ),
          (selectingElements)?IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool? result = await showDialog(context: context, builder: (_){
                  return AlertDialog(
                    title: Text("¿Eliminar los colectores seleccionados?"),
                    content: Text("¿Estás seguro de que quieres eliminar los colectores seleccionados?, no podra recuperarlos"),
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
                    print("eliminando colectores");
                    removeElement(1);
                  }
                }
              }
          ):Text(""),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {"Seleccionar todo",}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Shimmer(
            child: ShimmerLoading(
              isLoading: (loading && !deleting && !updating),
              child: ListView(
                children: getList(),
              ),
            ),
          ),
        ),
        floatingActionButton:ElevatedButton.icon(
          onPressed: (){
            Navigator.of(context).pushNamed(Routes.addCollector);
          },
          icon: const Icon(Icons.add),
          label:  const Text("Agregar colector"),
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
    mm.removeCollector(model: element.collector).then((v) {
      elements.remove(element);
      mm.collectors.remove(element.collector);
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
              content: Text("Se han elimnado $cant usuarios")),
        );
        _refresh();
      }
    });
  }
  List<Widget> getList(){
    List<Widget> list = [];
    if (elements.isNotEmpty){
      list.add(
          ListTile(
            leading: const Text(""),
            title: Text('Colectores',),
          )
      );
    }else{
      list.add(
          ListTile(
            leading: const Text(""),
            title: Text('No hay colectores'),
          )
      );
      list.add(
          Center(
            child:Icon(Icons.warning)
          )
      );
    }
    if (filtering){
      list.add(
          ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Filtrando colectores'),
          )
      );
    }

    bool isSelectingElements = false;
    for (var element in elements) {
      if (element.selected) {
        isSelectingElements = true;
      }
      if (element.collector.id != mm.user.id) {
        list.add(
          CollectorWidget(
            addUsers: (){
              showAddDialog(element);
            },
            onTapUser: (User user) async {
              element.updating = true;
              element.collector.listers.remove(user.id);
              await mm.updateCollector(model: element.collector);
              element.updating = false;
            },
            users: mm.users,
            element: element,
            onTap: () {
              if (selectingElements) {
                setState(() {
                  element.selected = !element.selected;
                });
              }
            },
            onLongPress: () {
              if (!selectingElements) {
                setState(() {
                  selectingElements = true;
                });
              }
              setState(() {
                element.selected = !element.selected;
              });
            } ,
            selectingElements: selectingElements,
          ),
        );
      }
    }
    list.add(Divider());
    list.add(
      ListTile(
        title: Text("Usuarios sin asignar un colector"),
      )
    );
    if (collectorModelOptions.hasMore){
      if (addingModels){
        list.add(
            Center(
                child: CircularProgressIndicator()
            )
        );
      }else{
        list.add(
            Center(
                child:IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    addingModels = true;
                    collectorModelOptions.page ++;
                    collectorModelOptions = await mm.updateCollectors(filter: collectorFilter, loadMore: true,page: collectorModelOptions.page);
                  },
                )
            )
        );
      }
    }
    if (!isSelectingElements && selectingElements){
      Future.delayed(Duration(milliseconds: 1),(){
        setState(() {
          selectingElements = false;
        });
      });
    }


    list.add(const Divider());
    list.add(
        ListTile(
            leading:Icon(Icons.info_outline),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('-Toca un colector para ver sus usuarios'),
                Row(
                    children: [
                      Text("-Toca en "),
                      Icon(Icons.filter_alt),
                      Text(" para filtrar los colectores")
                    ]
                ),
                Text('-Manten presionado un colector para eliminarlo'),
              ],
            )
        )
    );

    return list;
  }
  void showAddDialog(var element) {
    showDialog(
        context: context,
        builder: (c){
          return StatefulBuilder(
              builder: (c, StateSetter setState) {
                List<Widget> users = [];
                for (var user in mm.users) {
                  bool add = true;
                  for (var element in elements) {
                    if (element.collector.listers.contains(user.id)){
                      add  = false;
                    }
                  }
                  if (add) {
                    users.add(Divider());
                    users.add(
                        ListTile(

                          title: Text(user.username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("id: ${user.id}"),
                              Text("${(user.isSuperuser)? "Superusuario": (user.isStaff)?"Admin": "Listero"}"),
                            ],
                          ),

                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              setState(() {
                                element.collector.listers.add(user.id);
                                element.updating = true;
                              });
                              await mm.updateCollector(model: element.collector);
                              element.updating = false;
                            },
                          ),
                        )
                    );
                  }
                }
                return AlertDialog(
                  title: Text("Elige el usario a añadir"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: users,
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}

class CollectorElement {
  final Collector collector;
  bool selected;
  bool deleting = false;
  bool updating = false;
  CollectorElement({required this.collector, this.selected = false});
}
class CollectorWidget extends StatelessWidget {
  CollectorWidget({super.key, required this.element, required this.onTap, this.onLongPress, this.selectingElements = false, required this.users, this.onTapUser, this.addUsers});
  final CollectorElement element;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final void Function(User user)? onTapUser;
  final void Function()? addUsers;
  final List<User> users;
  final bool selectingElements;
  @override
  Widget build(BuildContext context){
    List<Widget> list = [];
    list.add(Divider());
    for (var user in users){
      if (element.collector.listers.contains(user.id)){
        list.add(
            ListTile(
              leading: Icon(Icons.person),
                title: Text(user.username),
              trailing: IconButton(
                icon: Icon(Icons.remove),
                onPressed:() {
                    element.collector.listers.remove(user.id);
                    onTapUser!(user);
                },
              ),
            )
        );
      }
    }
    list.add(Divider());
    list.add(
      ElevatedButton(
        child: Text("Añadir mas usuarios"),
        onPressed: addUsers,
      )
    );

    return Card(
      child: ExpansionTile(
        title: ListTile(
          leading: (selectingElements) ? Checkbox(
            value: element.selected,
            onChanged: (b) {},
          ) : null,
          selected: element.selected,
          onLongPress: onLongPress,
          trailing: (element.deleting || element.updating) ? CircularProgressIndicator() : null,
          title: Text("Id: ${element.collector.id} | '${element.collector.name}'"),
          subtitle: (element.updating)? Text("Actualizando colector...") : (element.deleting)? Text("Eliminando colector..."): Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${element.collector.listers.length} ${(element.collector.listers.length == 1)? "listero":"listeros"}"),
              Text("Colector creado: ${(element.collector.createdAt == null)
                  ? "No se sabe"
                  : element.collector.createdAt!.toLocal().toString().split(
                  ".")[0]}"),
            ],
          ),
          onTap: onTap,
        ),
        children: list
      ),
    );
  }
}
