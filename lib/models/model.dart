

import 'package:bolita_cubana/models/models.dart';
import 'package:bolita_cubana/views/views.dart';
import 'package:flutter/material.dart';

enum Models{
   disabledNumbers,
  disabledBets,
  play,
  padlock,
  user,
  collector,
  app

}

class Model{
  int id;

  Model({this.id = 0});

  Map<String, dynamic> toUpdateMap() {
    return {};
  }

  Map<String, dynamic> toCreateMap() {
    return {};
  }
  factory Model.fromMap(Map<String, dynamic> data, Models models,{Padlock? padlock, User? user}){
    switch(models){

      case Models.disabledNumbers:
        return DisabledNumbers.fromMap(data);

      case Models.play:
        return Play.fromMap(data, padlock!);

      case Models.padlock:
        return Padlock.fromMap(data, user!);

      case Models.user:
        return User.fromMap(data);

      case Models.app:
        return App.fromMap(data);

      case Models.collector:
        return Collector.fromMap(data);

      case Models.disabledBets:
        return DisabledBets.fromMap(data);
    }
  }

}