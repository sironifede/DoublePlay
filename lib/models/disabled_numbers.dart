import 'Model.dart';


class DisabledNumbers  extends Model{
  String id;
  List<int> dayNumbers;
  List<int> nightNumbers;
  int month;

  DisabledNumbers(
      {required this.id,
        required this.dayNumbers,
        required this.nightNumbers,
        required this.month,});

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "dayNumbers": dayNumbers,
      "nightNumbers": nightNumbers,
      "month": month,
    };
  }

  factory DisabledNumbers.fromMap(Map<String, dynamic> data){
    return DisabledNumbers(
      id: data["id"],
      dayNumbers: data["day_numbers"],
      nightNumbers: data["night_numbers"],
      month: data["month"],
    );
  }
}