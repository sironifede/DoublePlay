
import 'package:bolita_cubana/models/user.dart';

import 'model.dart';

class Padlock extends Model{
  int user;
  bool playing = false;
  int month;
  int moneyGenerated;
  bool selled;
  bool listerMoneyCollected;
  bool collectorMoneyCollected;
  String name;
  String phone;
  DateTime? createdAt;
  DateTime? updatedAt;

  Padlock({
    int id = 0,
    required this.user,
    required this.playing,
    required this.month,
    required this.moneyGenerated,
    required this.selled,
    required this.listerMoneyCollected,
    required this.collectorMoneyCollected,
    required this.name,
    required this.phone,
    this.createdAt,
    this.updatedAt,
  }):super(id: id);

  @override
  Map<String, dynamic> toUpdateMap(){
    return {
      "id": id.toString(),
      "playing": playing.toString(),
      "month": month.toString(),
      "selled": selled.toString(),
      "lister_money_collected": listerMoneyCollected.toString(),
      "collector_money_collected": collectorMoneyCollected.toString(),
      "name": name.toString(),
      "phone": phone.toString(),
    };
  }

  @override
  Map<String, dynamic> toCreateMap(){
    return {
      "playing": playing.toString(),
      "month": month.toString(),
      "selled": selled.toString(),
      "lister_money_collected": listerMoneyCollected.toString(),
      "collector_money_collected": collectorMoneyCollected.toString(),
      "name": name.toString(),
      "phone": phone.toString(),
    };
  }

  factory Padlock.fromMap(Map<String, dynamic> data){
    String date = (data["created_at"] == null)? "": data["created_at"];
    DateTime? createdAt = (data["created_at"] == null )? null :DateTime.utc(int.parse(date.split("-")[0]),int.parse(date.split("-")[1]),int.parse(date.split("-")[2].split("T")[0]),int.parse(date.split("-")[2].split("T")[1].split(":")[0]),int.parse(date.split("-")[2].split("T")[1].split(":")[1]),int.parse(date.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll("Z", "")));

    date = (data["updated_at"] == null)? "": data["updated_at"];
    DateTime? updatedAt = (data["updated_at"] == null )? null :DateTime.utc(int.parse(date.split("-")[0]),int.parse(date.split("-")[1]),int.parse(date.split("-")[2].split("T")[0]),int.parse(date.split("-")[2].split("T")[1].split(":")[0]),int.parse(date.split("-")[2].split("T")[1].split(":")[1]),int.parse(date.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll("Z", "")));

    return Padlock(
      id: data["id"],
      user: data["user"],
      playing: data["playing"],
      month: data["month"],
      moneyGenerated: data["money_generated"],
      selled: data["selled"],
      listerMoneyCollected: data["lister_money_collected"],
      collectorMoneyCollected: data["collector_money_collected"],
      name: data["name"],
      phone: data["phone"],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

}