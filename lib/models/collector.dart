
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
      "id": id.toString(),
      "listers": listers.toString(),
      "name": name
    };
  }
  @override
  Map<String, dynamic> toCreateMap(){
    return {
      "listers":listers.toString(),
      "name":  name
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
    List<int> listers = [];
    if (data["listers"] != ""){
      String ds = data["listers"].toString().substring(1);
      ds = ds.substring(0,ds.length - 1).trim();
      for (var i in ds.split(",")){
        try {
          listers.add(int.parse(i.toString()));
        }catch(e){}
      }
    }
    return Collector(
      id: data["id"],
      listers: listers,
      name: data["name"],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}