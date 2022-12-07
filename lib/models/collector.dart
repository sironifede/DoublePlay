
import 'package:bolita_cubana/models/user.dart';

import 'model.dart';


class Collector extends Model{

  List<int> listers;
  bool moneyCollcted;
  User user;
  Collector(
      {
        required int id,
        required this.listers,
        required this.user,
        required this.moneyCollcted,
      }
      ):super(id: id);


  @override
  Map<String, dynamic> toUpdateMap(){
    return {
      "listers": listers.toString(),
      "user_id": user.id.toString(),
      "user": user.id.toString(),
      "money_collected": moneyCollcted.toString(),
    };
  }
  @override
  Map<String, dynamic> toCreateMap(){
    return {
      "listers":listers.toString(),
      "user_id": user.id.toString(),
      "user": user.id.toString(),
      "money_collected": moneyCollcted.toString(),
    };
  }

  factory Collector.fromMap(Map<String, dynamic> data, User user){
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
      id: data["user"],
      listers: listers,
      user: user,
      moneyCollcted:data["money_collected"],
    );
  }
}