import 'filter.dart';

class PlayFilter extends Filter {
  ListFilterField padlock = ListFilterField(
      labelText: "Numero de confirmacion", hintText: "Numero de confirmacion", fieldName: "padlock");
  BooleanFilterField confirmed = BooleanFilterField(
      labelText: "Jugada terminada", hintText: "Si se confirmo la jugada",fieldName: "confirmed");

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

  PlayFilter({
    List<int>? padlocks,
    bool? confirmed,
    String month = "",
    String type = "",
    String bet = "",
    String dayNumber = "",
    String nightNumber = "",
    String betGT = "",
  }) {
    if (padlocks != null){
      this.padlock.values = padlocks;
    }
    this.confirmed.value = confirmed;
    this.month.value = month;
    this.type.value = type;
    this.dayNumber.value = dayNumber;
    this.nightNumber.value = nightNumber;
    this.bet.value = bet;
    this.betGT.value = betGT;
  }

  @override
  String getFilterStr() {
    String filterStr = "?";
    List<FilterField> fields = [
      padlock,
      confirmed,
      month,
      dayNumber,
      nightNumber,
      type,
      bet,
      betGT
    ];
    for (var field in fields) {

      if (field.runtimeType.toString() == "ListFilterField"){
        filterStr += "${field.getValue}";
      }else{
        try{
          DateTime date = DateTime.parse(field.getValue);
          filterStr += "${field.getFieldName}=${date.toUtc()}&";
        }catch(e){

          filterStr += "${field.getFieldName}=${field.getValue}&";
        }
      }
    }
    return filterStr;
  }
}