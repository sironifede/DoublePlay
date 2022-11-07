import 'dart:convert';
import 'package:bolita_cubana/filters/filter.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';



class FetchedUsers {
  List<User> models;
  bool hasMore;
  FetchedUsers({required this.models, required this.hasMore});
}
Future<FetchedUsers> fetchUsers({required User user, Filter? filter, int page = 1} ) async {


  final response = await http.get(
    Uri.parse('http://doubleplay.herokuapp.com/api/users/${(filter != null)?filter.getFilterStr() + "page=$page": "?page=$page"}'),
    headers: <String, String>{
      'Authorization': 'token ' + user.token!,
    },

  );
  print(response.statusCode);

  if (response.statusCode == 200) {

    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map listMap ;

    List<User> list = [];
    bool hasMore = false;
    try{
      listMap = jsonDecode(utf8.decode(response.bodyBytes));
      if (listMap["next"] != null){
        hasMore = true;
      }
      listMap["results"].forEach((row) {
        try {
          User model = User.fromMap(row);
          list.add(model);
        }catch (e){
          print("Users error  $e");
        }
      });
    } catch (e) {
      throw Exception("cant decode body. " + e.toString());
    }
    return FetchedUsers(models: list, hasMore: hasMore);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  }
}

Future<User> getUser({required User user}) async {

  final response = await http.get(
    Uri.parse('http://doubleplay.herokuapp.com/api/user/'),
    headers: <String, String>{
      'Authorization': 'token ' + user.token!,
    },

  );

  print(response.statusCode);
  User? model;
  if (response.statusCode == 200) {

    // If the server did return a 200 OK response,
    // then parse the JSON.
    List listMap ;

    try{
      listMap = jsonDecode(utf8.decode(response.bodyBytes));

      listMap.forEach((row) {
        try {
          model = User.fromMap(row);
        }catch (e){
          print("User error  $e");
        }
      });
    } catch (e) {
      throw Exception("cant decode body. " + e.toString());
    }
    return model!;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  }
}

Future<bool> deleteUser({required User user, required User userToDelete}) async {

  final response = await http.delete(
    Uri.parse('http://doubleplay.herokuapp.com/api/users/${userToDelete.id}/'),
    headers: <String, String>{
      'Authorization': 'token ' + user.token!,
    },

  );
  print(response.statusCode);
  if (response.statusCode == 204) {
    return true;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  }
}