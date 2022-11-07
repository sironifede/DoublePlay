import 'filter.dart';

class PlayFilter extends Filter {
  TextFilterField user = TextFilterField(
      labelText: "Usuario", hintText: "", fieldName: "user");
  TextFilterField month = TextFilterField(
      labelText: "Mes", hintText: "Mes de la jugada", fieldName: "month");
  TextFilterField type = TextFilterField(labelText: "Tipo de jugada",
      hintText: "Que tipo de jugada se hizo",
      fieldName: "type");
  TextFilterField dayNumber = TextFilterField(labelText: "Numero de dia",
      hintText: "El numero que se eligio de dia",
      fieldName: "day_number");
  TextFilterField dayNumberGT = TextFilterField(
      labelText: "Numeros de dia mayores a",
      hintText: "Numeros de dia mayores a",
      fieldName: "day_number__gt");
  TextFilterField nightNumber = TextFilterField(labelText: "Numero de noche",
      hintText: "El numero que se eligio de noche",
      fieldName: "night_number");
  TextFilterField nightNumberGT = TextFilterField(
      labelText: "Numeros de noche mayores a",
      hintText: "Numeros de noche mayores a",
      fieldName: "night_number__gt");
  TextFilterField bet = TextFilterField(
      labelText: "Apuesta", hintText: "Dinero de la apuesta", fieldName: "bet");
  TextFilterField betGT = TextFilterField(labelText: "Apuestas mayores a",
      hintText: "Apuestas mayores a",
      fieldName: "bet__gt");

  PlayFilter({
    String user = "",
    String month = "",
    String type = "",
    String dayNumber = "",
    String dayNumberGT = "",
    String nightNumber = "",
    String nightNumberGT = "",
    String bet = "",
    String betGT = "",
  }) {
    this.user.value = user;
    this.month.value = month;
    this.type.value = type;
    this.dayNumber.value = dayNumber;
    this.dayNumberGT.value = dayNumberGT;
    this.nightNumber.value = nightNumber;
    this.nightNumberGT.value = nightNumberGT;
    this.bet.value = bet;
    this.betGT.value = betGT;
  }

  @override
  String getFilterStr() {
    String filterStr = "?";
    List<FilterField> fields = [
      user,
      month,
      type,
      dayNumber,
      dayNumberGT,
      nightNumber,
      nightNumberGT,
      bet,
      betGT
    ];
    for (var field in fields) {
      filterStr += "${field.getFieldName}=${field.getValue}&";
    }
    return filterStr;
  }
}