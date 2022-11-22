import 'filter.dart';

class PlayFilter extends Filter {
  TextFilterField padlock = TextFilterField(
      labelText: "Numero de confirmacion", hintText: "Numero de confirmacion", fieldName: "padlock");
  BooleanFilterField confirmed = BooleanFilterField(
      labelText: "Jugada terminada", hintText: "Si se confirmo la jugada",fieldName: "confirmed");

  TextFilterField type = TextFilterField(labelText: "Tipo de jugada",
      hintText: "Que tipo de jugada se hizo",
      fieldName: "type");
  TextFilterField bet = TextFilterField(
      labelText: "Apuesta", hintText: "Dinero de la apuesta", fieldName: "bet");
  TextFilterField betGT = TextFilterField(labelText: "Apuestas mayores a",
      hintText: "Apuestas mayores a",
      fieldName: "bet__gt");

  PlayFilter({
    String padlock = "",
    bool? confirmed,
    String type = "",
    String bet = "",
    String betGT = "",
  }) {
    this.padlock.value = padlock;
    this.confirmed.value = confirmed;
    this.type.value = type;
    this.bet.value = bet;
    this.betGT.value = betGT;
  }

  @override
  String getFilterStr() {
    String filterStr = "?";
    List<FilterField> fields = [
      padlock,
      confirmed,
      type,
      bet,
      betGT
    ];
    for (var field in fields) {
      filterStr += "${field.getFieldName}=${field.getValue}&";
    }
    return filterStr;
  }
}