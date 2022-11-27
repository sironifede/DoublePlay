import 'package:flutter/material.dart';

import 'model.dart';

class App  extends Model{
  bool active;
  TimeOfDay stopHour;


  App({int id = 0,required this.active, required this.stopHour}):super(id: id);


  @override
  Map<String, dynamic> toUpdateMap() {
    var now = DateTime.now();
    var local = DateTime(now.year,now.month,now.day,stopHour.hour,stopHour.minute).toUtc();
    return {
      "active": active.toString(),
      "stop_hour": "${local.hour}:${local.minute}:00",
    };
  }

  factory App.fromMap(Map<String, dynamic> data) {
    var now = DateTime.now();

    var utc = DateTime.utc(now.year,now.month,now.day,int.parse(data["stop_hour"].split(":")[0]),int.parse(data["stop_hour"].split(":")[1]));

    print("now $now");
    print("stop_hour_utc: ${utc}");
    print("stop_hour_local: ${utc.toLocal()}");
    return App(
      id: data["id"],
      active: data["active"],
      stopHour: TimeOfDay(hour: utc.toLocal().hour,minute: utc.toLocal().minute),
    );
  }
}
