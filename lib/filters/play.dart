import 'filter.dart';

class PlayFilter extends Filter {
  ListFilterField padlock = ListFilterField(
      labelText: "Numero de confirmacion", hintText: "Numero de confirmacion", fieldName: "padlock");
  BooleanFilterField confirmed = BooleanFilterField(
      labelText: "Jugada terminada", hintText: "Si se confirmo la jugada",fieldName: "confirmed");
  BooleanFilterField selled = BooleanFilterField(
      labelText: "", hintText: "",fieldName: "padlock__selled");
  TextFilterField type = TextFilterField(labelText: "Tipo de jugada",
      hintText: "Que tipo de jugada se hizo",
      fieldName: "type");
  TextFilterField month = TextFilterField(
      labelText: "Mes", hintText: "Mes de la jugada", fieldName: "month");

  TextFilterField dayNumber = TextFilterField(labelText: "",
      hintText: "",
      fieldName: "day_number");
  TextFilterField nightNumber = TextFilterField(labelText: "",
      hintText: "",
      fieldName: "night_number");
  TextFilterField bet = TextFilterField(
      labelText: "Apuesta", hintText: "Dinero de la apuesta", fieldName: "bet");
  TextFilterField betGT = TextFilterField(labelText: "Apuestas mayores a",
      hintText: "Apuestas mayores a",
      fieldName: "bet__gt");
  ListFilterField user = ListFilterField(
      labelText: "", hintText: "", fieldName: "padlock__user");

  TextFilterField creAtLt = TextFilterField(labelText: "Creado antes de ", hintText: "Fecha de creacion menor",fieldName: "padlock__created_at__lt");
  TextFilterField creAtGt = TextFilterField(labelText: "Creado despues de ", hintText: "Fecha de creacion mayor",fieldName: "padlock__created_at__gt");



  PlayFilter({
    List<int>? padlocks,
    List<int>? users,
    bool? confirmed,
    bool? selled,
    String month = "",
    String type = "",
    String bet = "",
    String dayNumber = "",
    String nightNumber = "",
    String betGT = "",
    String creAtLt = "",
    String creAtGt = "",
  }) {
    if (padlocks != null){
      this.padlock.values = padlocks;
    }
    this.confirmed.value = confirmed;
    this.selled.value = selled;
    this.month.value = month;
    this.type.value = type;
    this.dayNumber.value = dayNumber;
    this.nightNumber.value = nightNumber;
    this.bet.value = bet;
    this.betGT.value = betGT;
    this.creAtLt.value = creAtLt;
    this.creAtGt.value = creAtGt;
    if (users != null){
      this.user.values = users;
    }

  }

  @override
  String getFilterStr() {
    String filterStr = "?";
    List<FilterField> fields = [
      super.idIn,
      padlock,
      confirmed,
      selled,
      month,
      dayNumber,
      nightNumber,
      type,
      bet,
      betGT,
      creAtLt,
      creAtGt,
      user
    ];
    for (var field in fields) {
      filterStr += "${field.getHeader}";
    }
    return filterStr;
  }
}