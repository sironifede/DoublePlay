import 'filter.dart';

class PadlockFilter extends Filter {


  ListFilterField user = ListFilterField(
      labelText: "Listero", hintText: "Listero del candado", fieldName: "user");
  BooleanFilterField playing = BooleanFilterField(
      labelText: "Jugando", hintText: "Si sigue en una jugada",fieldName: "playing");
  BooleanFilterField selled = BooleanFilterField(
      labelText: "", hintText: "",fieldName: "selled");
  BooleanFilterField listerMoneyCollected = BooleanFilterField(
      labelText: "", hintText: "",fieldName: "lister_money_collected");
  BooleanFilterField collectorMoneyCollected = BooleanFilterField(
      labelText: "", hintText: "",fieldName: "collector_money_collected");
  TextFilterField month = TextFilterField(
      labelText: "Mes", hintText: "Mes de la jugada", fieldName: "month");
  TextFilterField name = TextFilterField(
      labelText: "Nombre", hintText: "Nombre del usuario", fieldName: "name");
  TextFilterField phone = TextFilterField(
      labelText: "Telefono", hintText: "Telefono del usuario", fieldName: "phone");
  TextFilterField creAtLt = TextFilterField(labelText: "Creado antes de ", hintText: "Fecha de creacion menor",fieldName: "created_at__lt");
  TextFilterField creAtGt = TextFilterField(labelText: "Creado despues de ", hintText: "Fecha de creacion mayor",fieldName: "created_at__gt");



  PadlockFilter({
    List<int>? users,
    bool? playing,
    bool? selled,
    bool? listerMoneyCollected,
    bool? collectorMoneyCollected,
    String month = "",
    String name = "",
    String phone = "",
    String creAtLt = "",
    String creAtGt = "",
  }) {
    if (users != null){
      this.user.values = users;
    }

    this.listerMoneyCollected.value = listerMoneyCollected;
    this.collectorMoneyCollected .value = collectorMoneyCollected;
    this.playing.value = playing;
    this.month.value = month;
    this.selled.value = selled;
    this.name.value = name;
    this.phone.value = phone;
    this.creAtLt.value = creAtLt;
    this.creAtGt.value = creAtGt;

  }

  @override
  String getFilterStr() {
    String filterStr = "?";
    List<FilterField> fields = [
      super.idIn,
      user,
      playing,
      selled,
      listerMoneyCollected,
      collectorMoneyCollected,
      month,
      name,
      phone,
      creAtLt,
      creAtGt,
    ];

    for (var field in fields) {
      filterStr += "${field.getHeader}";
    }
    return filterStr;
  }
}