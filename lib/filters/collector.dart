import 'filter.dart';

class CollectorFilter extends Filter{
  TextFilterField name = TextFilterField(labelText: "Nombre", hintText: "Nombre de colector",fieldName: "name__icontains");
  TextFilterField listers = TextFilterField(labelText: "Nombre de listeros", hintText: "Nombre de listeros dentro del colector",fieldName: "listers");


  CollectorFilter({
    String name = "",
    String listers = "",
  }){
    this.name.value = name;
    this.listers.value = listers;
  }

  @override
  String getFilterStr(){
    String filterStr = "?";
    List<FilterField> fields = [name,listers];
    for (var field in fields) {
      filterStr += "${field.getFieldName}=${field.getValue}&";
    }
    return filterStr;
  }
}