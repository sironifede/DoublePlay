import 'package:flutter/material.dart';

import 'Model.dart';

class App  extends Model{
  bool active;
  TimeOfDay stopHour;


  App({required this.active, required this.stopHour});

  factory App.fromMap(Map<String, dynamic> data) {
     return App(
       active: data["active"],
       stopHour: TimeOfDay(hour: int.parse(data["stop_hour"].split(":")[0]),minute: int.parse(data["stop_hour"].split(":")[1])),
     );
  }
  Map<String, dynamic> toMap() {
    return {
      "active": active.toString(),
      "stop_hour": "${stopHour.hour}:${stopHour.minute}:00",
    };
  }
}
