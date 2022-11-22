
import 'model.dart';


class Collector extends Model{

  List<int> listers;
  String name;
  DateTime? createdAt;
  DateTime? updatedAt;
  Collector(
      {
        required int id,
        required this.listers,
        required this.name,
        this.createdAt,
        this.updatedAt,
      }
      ):super(id: id);


  @override
  Map<String, dynamic> toUpdateMap(){
    return {
      "id": id,
      "listers": "$listers",
      "name": name,
    };
  }
  @override
  Map<String, dynamic> toCreateMap(){
    return {
      "listers": "$listers",
      "name": name,
    };
  }

  factory Collector.fromMap(Map<String, dynamic> data){
    String? date = (data["created_at"] == null) ? "" : data["created_at"];
    DateTime? createdAt = (date == null) ? null : DateTime.utc(
        int.parse(date.split("-")[0]), int.parse(date.split("-")[1]),
        int.parse(date.split("-")[2].split("T")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[1]), int.parse(
        date.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll(
            "Z", "")));

    date = (data["updated_at"] == null) ? "" : data["updated_at"];
    DateTime? updatedAt = (date == null) ? null : DateTime.utc(
        int.parse(date.split("-")[0]), int.parse(date.split("-")[1]),
        int.parse(date.split("-")[2].split("T")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[1]), int.parse(
        date.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll(
            "Z", "")));
    List<int> list = [];
    for (var i in data["listers"]){
      try {
        list.add(i as int);
      }catch(e){}
    }
    return Collector(
      id: data["id"],
      listers: list,
      name: data["name"],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}