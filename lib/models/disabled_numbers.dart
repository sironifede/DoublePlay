import 'model.dart';


class DisabledNumbers  extends Model{

  List<int> dayNumbers;
  List<int> nightNumbers;
  int month;

  DisabledNumbers(
      {int id = 0,
        required this.dayNumbers,
        required this.nightNumbers,
        required this.month,}):super(id: id);


  @override
  Map<String, dynamic> toUpdateMap(){
    return {
      "day_numbers": dayNumbers.toString(),
      "night_numbers": nightNumbers.toString(),
      "month": month.toString(),
    };
  }

  factory DisabledNumbers.fromMap(Map<String, dynamic> data){
    List<int> dayNumbers = [];
    List<int> nightNumbers = [];
    if (data["day_numbers"] != ""){
      String ds = data["day_numbers"].toString().substring(1);
      ds = ds.substring(0,ds.length - 1).trim();
      for (var i in ds.split(",")){
        try {
          dayNumbers.add(int.parse(i));
        }catch(e){}
      }
    }
    if (data["night_numbers"] != ""){
      String ns = data["night_numbers"].toString().substring(1);
      ns = ns.substring(0,ns.length - 1).trim();
      for (var i in ns.split(",")){
        try {
          nightNumbers.add(int.parse(i));
        }catch(e){}
      }
    }
    return DisabledNumbers(
      id: data["id"],
      dayNumbers: dayNumbers,
      nightNumbers: nightNumbers,
      month: data["month"],
    );
  }
}