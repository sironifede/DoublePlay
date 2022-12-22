import 'package:bolita_cubana/models/user.dart';

import 'model.dart';

class Collector extends Model {
  List<int> listers;
  int user;

  Collector({
    required int id,
    required this.listers,
    required this.user,
  }) : super(id: id);

  @override
  Map<String, dynamic> toUpdateMap() {
    return {
      "listers": listers.toString(),
      "user_id": user.toString(),
      "user": user.toString(),
    };
  }

  @override
  Map<String, dynamic> toCreateMap() {
    return {
      "listers": listers.toString(),
      "user_id": user.toString(),
      "user": user.toString(),
    };
  }

  factory Collector.fromMap(Map<String, dynamic> data) {
    List<int> listers = [];
    if (data["listers"] != "") {
      String ds = data["listers"].toString().substring(1);
      ds = ds.substring(0, ds.length - 1).trim();
      for (var i in ds.split(",")) {
        try {
          listers.add(int.parse(i.toString()));
        } catch (e) {}
      }
    }
    return Collector(
      id: data["user"],
      listers: listers,
      user: data["user"],
    );
  }


}
