
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../filters/filters.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import '../../routes/route_generator.dart';
import '../shimmer.dart';
import '../views.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool loading = true;
  bool filtering = false;
  bool addingModels = false;
  bool selectingElements = false;
  List<UserElement> elements = [];
  late ModelsManager mm;
  ModelOptions userModelOptions = ModelOptions(hasMore: false, page: 1);

  TextEditingController _usernameController = TextEditingController();
  List<String> userTypes = <String>['Admins', 'Superusuarios', 'Listeros', 'Colectores'];
  String userType = 'Listeros';
  UserFilter userFilter = UserFilter(isStaff: false, isSuperUser: false);

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
      await _refresh();
    });
  }
  Future<void> _refresh() async {
    userModelOptions = await mm.updateUsers(filter: userFilter);
    if (userType == userTypes[3]) {
      await mm.updateCollectors();
      List<User> users =[];
      for (var user in mm.users){
        if (user.isCollector){
          users.add(user);
        }
      }
      mm.users = users;
    }else if (userType == userTypes[2]) {
      await mm.updateCollectors();
      List<User> users =[];
      for (var user in mm.users){
        if (!user.isCollector){
          users.add(user);
        }
      }
      mm.users = users;
    }
  }
  @override
  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    if (!selectingElements){
      elements = [];
      for (var user in mm.users) {
        elements.add(UserElement(user: user));
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
        title: Text("Administrar usuarios"),
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
                                    controller: _usernameController,
                                    decoration: const InputDecoration(
                                      labelText: "Nombre de usuario",
                                      hintText: "Nombre de usuario",
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: userType,
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        userType = value!;
                                      });
                                    },
                                    items: userTypes.map<
                                        DropdownMenuItem<String>>((
                                        String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
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
                                      if (userType == userTypes[0]) {
                                        userFilter.isStaff.value = true;
                                        userFilter.isSuperUser.value = false;
                                        print(userFilter.getFilterStr());
                                      } else if (userType == userTypes[1]) {
                                        userFilter.isStaff.value = true;
                                        userFilter.isSuperUser.value = true;
                                        print(userFilter.getFilterStr());
                                      } else {
                                        userFilter.isStaff.value = false;
                                        userFilter.isSuperUser.value = false;
                                        print(userFilter.getFilterStr());
                                      }
                                      selectingElements = false;
                                      userFilter.username.value =
                                          _usernameController.text;
                                      filtering = true;
                                      Navigator.of(context).pop();
                                      _refresh();
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
          child:Shimmer(
            child: ShimmerLoading(
              isLoading: loading,
              child: ListView(
                children: getList(),
              ),
            ),
          ),
        ),
        floatingActionButton:ElevatedButton.icon(
          onPressed: (){
            Navigator.of(context).pushNamed(Routes.registerUser);
          },
          icon: const Icon(Icons.add),
          label:  const Text("Agregar usuario"),
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
    mm.removeUser(model: element.user).then((v) {
      elements.remove(element);
      mm.users.remove(element.user);
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
            title: Text('Usuarios',style: TextStyle(color: Theme.of(context).primaryColor),),
          )
      );
    }else{
      list.add(
          ListTile(
            leading: const Text(""),
            title: Text('No hay usuarios',style: TextStyle(color: Theme.of(context).primaryColor),),
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
            title: Text('Filtrando usuarios'),
          )
      );
    }

    bool isSelectingElements = false;
    for (var element in elements) {
      if (element.selected) {
        isSelectingElements = true;
      }
      if (element.user.id != mm.user.id) {
        list.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OpenContainer(
              openBuilder: (_, closeContainer) => const UserPage(),
              tappable: false,
              closedColor: Theme.of(context).dialogBackgroundColor,
              openColor: Colors.transparent,
              closedBuilder: (_, openContainer) =>
                  UserWidget(
                    element: element,
                    onTap: () {

                      if (selectingElements) {
                        if (!(!mm.user.isSuperuser && (element.user.isSuperuser || element.user.isStaff))){
                          setState(() {
                            element.selected = !element.selected;
                          });
                        }
                      } else {
                        mm.selectUser(element.user);
                        openContainer();
                      }
                    },
                    onLongPress: (!mm.user.isSuperuser && (element.user.isSuperuser || element.user.isStaff))? null :() {
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
            ),
          ),
        );
      }
    }
    if (userModelOptions.hasMore){
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
                    userModelOptions.page ++;
                    userModelOptions = await mm.updateUsers(filter: userFilter, loadMore: true,page: userModelOptions.page);
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
                Text('-Toca un usario para verlo'),
                Row(
                    children: [
                      Text("-Toca en "),
                      Icon(Icons.filter_alt),
                      Text(" para filtrar los usuarios")
                    ]
                ),
                Text('-Manten presionado un usurios para eliminarlo'),
              ],
            )
        )
    );

    return list;
  }
}

class UserElement {
  final User user;
  bool selected;
  bool deleting = false;
  UserElement({required this.user, this.selected = false});
}
class UserWidget extends StatelessWidget {
  const UserWidget({super.key, required this.element, required this.onTap, this.onLongPress, this.selectingElements = false});
  final UserElement element;
  final void Function()? onLongPress;
  final void Function()? onTap;
  final bool selectingElements;
  @override
  Widget build(BuildContext context){
    return ListTile(
      leading: (selectingElements)?Checkbox(
        value: element.selected,
        onChanged: (b){
        },
      ) : Icon(Icons.person),
      selected: element.selected,
      onLongPress: onLongPress,
      trailing:(element.deleting)? CircularProgressIndicator(): Icon(Icons.remove_red_eye),
      title: Text(element.user.username),
      subtitle: (element.deleting)?Text("Eliminando usuario..."):Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${(element.user.isSuperuser)? "Superusuario": (element.user.isStaff)?"Admin": (element.user.isCollector)?"Colector":"Listero"}"),
          Text("Cuenta creada el: ${(element.user.dateJoined== null)?"No se sabe": element.user.dateJoined!.toLocal().toString().split(".")[0]}"),
        ],
      ),
      onTap: onTap,
    );
  }
}
