import 'model.dart';

class DisabledBets extends Model {
  List<int> betNumbers;
  int month;

  DisabledBets({
    int id = 0,
    required this.betNumbers,
    required this.month,
  }) : super(id: id);

  @override
  Map<String, dynamic> toUpdateMap() {
    return {
      "bets": betNumbers.toString(),
      "month": month.toString(),
    };
  }

  factory DisabledBets.fromMap(Map<String, dynamic> data) {
    List<int> betsNumbers = [];
    if (data["bets"] != "") {
      String ds = data["bets"].toString().substring(1);
      ds = ds.substring(0, ds.length - 1).trim();
      for (var i in ds.split(",")) {
        try {
          betsNumbers.add(int.parse(i));
        } catch (e) {}
      }
    }

    return DisabledBets(
      id: data["id"],
      betNumbers: betsNumbers,
      month: data["month"],
    );
  }
}
