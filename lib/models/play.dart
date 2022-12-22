
import 'package:bolita_cubana/models/padlock.dart';

import 'model.dart';

enum PlayType{
  // ignore: constant_identifier_names
  JDA,
  // ignore: constant_identifier_names
  JD,
  // ignore: constant_identifier_names
  JSA,
  // ignore: constant_identifier_names
  JS
}
class Play extends Model{
  int padlock;
  bool confirmed;
  int nRandom;
  PlayType type;
  int dayNumber;
  int nightNumber;
  int bet;
  DateTime? createdAt;
  DateTime? updatedAt;

  Play({
    required int id,
    required this.padlock,
    required this.confirmed,
    required this.nRandom,
    required this.type,
    required this.dayNumber,
    required this.nightNumber,
    required this.bet,
    this.createdAt,
    this.updatedAt,
    }):super(id: id);


  @override
  Map<String, dynamic> toCreateMap() {
    return {
      "confirmed": confirmed.toString(),
      "type": type.name,
      "day_number": dayNumber.toString(),
      "night_number": nightNumber.toString(),
      "bet": bet.toString(),
    };
  }

  @override
  Map<String, dynamic> toUpdateMap(){
    return {
      "id": id.toString(),
      "padlock": padlock.toString(),
      "confirmed": confirmed.toString(),
      "type":type.name,
      "day_number": dayNumber.toString(),
      "night_number": nightNumber.toString(),
      "bet": bet.toString(),
    };
  }

  factory Play.fromMap(Map<String, dynamic> data){
    PlayType play = PlayType.values[data["type"]];;
    /*
    if (data["type"] == "JSA") {
      play = PlayType.JSA;
    } else if (data["type"] == "JD") {
      play = PlayType.JD;
    } else if (data["type"] == "JDA") {
      play = PlayType.JDA;
    }
    */
    String date = (data["created_at"] == null) ? "" : data["created_at"];
    DateTime? createdAt = (data["created_at"] == null) ? null : DateTime.utc(
        int.parse(date.split("-")[0]), int.parse(date.split("-")[1]),
        int.parse(date.split("-")[2].split("T")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[1]), int.parse(
        date.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll(
            "Z", "")));

    date = (data["updated_at"] == null) ? "" : data["updated_at"];
    DateTime? updatedAt = (data["updated_at"] == null) ? null : DateTime.utc(
        int.parse(date.split("-")[0]), int.parse(date.split("-")[1]),
        int.parse(date.split("-")[2].split("T")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[0]),
        int.parse(date.split("-")[2].split("T")[1].split(":")[1]), int.parse(
        date.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll(
            "Z", "")));

    return Play(
      id: data["id"],
      padlock: data["padlock"],
      confirmed: data["confirmed"],
      nRandom: data["n_random"],
      type: play,
      dayNumber: data["day_number"],
      nightNumber: data["night_number"],
      bet: data["bet"],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

}