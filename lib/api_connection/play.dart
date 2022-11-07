import 'dart:convert';
import 'package:bolita_cubana/api_connection/apis.dart';
import 'package:bolita_cubana/filters/filter.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';


class FetchedPlays {
  List<Play> models;
  bool hasMore;
  FetchedPlays({required this.models, required this.hasMore});
}
Future<FetchedPlays> fetchPlays({required User user, Filter? filter,int page = 1}) async {


  final response = await http.get(
    Uri.parse('http://doubleplay.herokuapp.com/api/plays/${(filter != null)?filter.getFilterStr() + "page=$page": "?page=$page"}'),
    headers: <String, String>{
      'Authorization': 'token ' + user.token!,
    },
  );
  print(response.statusCode);

  if (response.statusCode == 200) {

    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map listMap ;
    List<Play> list = [];
    bool hasMore = false;
    try{
      listMap = jsonDecode(utf8.decode(response.bodyBytes));
      if (listMap["next"] != null){
        hasMore = true;
      }
      List<User> users = (await fetchUsers(user: user)).models;
      for (var row in listMap["results"]) {
        try {
          User? user;
          for (user in users) {
            if (user.id == row["id"]){
              break;
            }
          }
          print(user!.username);
          Play model = Play.fromMap(row, user!);
          list.add(model);
        }catch (e){
          print("Plays error  $e");
        }
      }
    } catch (e) {
      throw Exception("cant decode body. " + e.toString());
    }
    return FetchedPlays(models: list, hasMore: hasMore);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  }
}
