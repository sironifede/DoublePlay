import 'filter.dart';

class UserFilter extends Filter{
  TextFilterField username = TextFilterField(labelText: "Usuario", hintText: "Nombre de usuario",fieldName: "username__icontains");
  BooleanFilterField isSuperUser = BooleanFilterField(labelText: "Super usuario", hintText: "Si el usuario tiene todos los permisos",fieldName: "is_superuser");
  BooleanFilterField isStaff = BooleanFilterField(labelText: "Usuario admin", hintText: "Si el usuario es administrador",fieldName: "is_staff");
  TextFilterField dateJoined = TextFilterField(labelText: "Creado", hintText: "Fecha en la que se creo el usuario",fieldName: "date_joined__iexact");
  TextFilterField dateJoinedGt = TextFilterField(labelText: "Creado despues de", hintText: "Usuarios que se crearon despues de una fecha",fieldName: "date_joined__gt");

  UserFilter({
    String username = "",
    bool? isSuperUser,
    bool? isStaff,
    String dateJoined = "",
    String dateJoinedGt = "",
  }){
    this.username.value = username;
    this.isSuperUser.value = isSuperUser;
    this.isStaff.value = isStaff;
    this.dateJoined.value = dateJoined;
    this.dateJoinedGt.value = dateJoinedGt;
  }

  @override
  String getFilterStr(){
    String filterStr = "?";
    List<FilterField> fields = [
      super.idIn,
      username,
      isSuperUser,
      isStaff,
      dateJoined,
      dateJoinedGt
    ];
    for (var field in fields) {
      filterStr += "${field.getHeader}";
    }
    return filterStr;
  }
}