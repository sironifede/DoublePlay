

import 'package:bolita_cubana/models/models.dart';
import 'package:bolita_cubana/views/views.dart';
import 'package:flutter/material.dart';

enum ModelType{
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
  factory Model.fromMap(Map<String, dynamic> data, ModelType models,{Padlock? padlock, User? user}){
    switch(models){

      case ModelType.disabledNumbers:
        return DisabledNumbers.fromMap(data);

      case ModelType.play:
        return Play.fromMap(data, padlock!);

      case ModelType.padlock:
        return Padlock.fromMap(data, user!);

      case ModelType.user:
        return User.fromMap(data);

      case ModelType.app:
        return App.fromMap(data);

      case ModelType.collector:
        print(Collector.fromMap(data, user!).toUpdateMap());
        return Collector.fromMap(data, user!);


      case ModelType.disabledBets:
        return DisabledBets.fromMap(data);
    }
  }

}