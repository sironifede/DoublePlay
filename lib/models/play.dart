
import 'package:bolita_cubana/models/user.dart';

import 'Model.dart';

enum PlayType{
  JDA,
  JD,
  JSA,
  JS
}
class Play extends Model{
  int id;
  User user;
  int month;
  PlayType type;
  int dayNumber;
  int nightNumber;
  int bet;
  DateTime? createdAt;

  Play({
    required this.id,
    required this.user,
    required this.month,
    required this.type,
    required this.dayNumber,
    required this.nightNumber,
    required this.bet,
    required this.createdAt,
    });

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "user": user.id,
      "month": month,
      "type": type.toString(),
      "day_number": dayNumber,
      "night_number": nightNumber,
      "bet": bet,
      "created_at": createdAt,
    };
  }

  factory Play.fromMap(Map<String, dynamic> data, User user){
    PlayType play = PlayType.JS;
    if (data["type"]== "JSA"){
      play = PlayType.JSA;
    }else if (data["type"]== "JD"){
      play = PlayType.JD;
    }else if (data["type"]== "JDA"){
      play = PlayType.JDA;
    }
    String date = (data["created_at"] == null)? "": data["created_at"];
    DateTime? createdAt = (data["created_at"] == null )? null :DateTime.utc(int.parse(date.split("-")[0]),int.parse(date.split("-")[1]),int.parse(date.split("-")[2].split("T")[0]),int.parse(date.split("-")[2].split("T")[1].split(":")[0]),int.parse(date.split("-")[2].split("T")[1].split(":")[1]),int.parse(date.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll("Z", "")));
    return Play(
      id: data["id"],
      user: user,
      month: data["month"],
      type: play,
      dayNumber: data["day_number"],
      nightNumber: data["night_number"],
      bet: data["bet"],
      createdAt:createdAt,
    );
  }

}