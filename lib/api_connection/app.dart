import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';



Future<App> fetchApp({required User user}) async {


  final response = await http.get(
    Uri.parse('http://doubleplay.herokuapp.com/api/app/1/'),
    headers: <String, String>{
      'Authorization': 'token ' + user.token!,
    },
  );
  print(response.statusCode);

  if (response.statusCode == 200) {

    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> map ;
    App app;
    map = jsonDecode(utf8.decode(response.bodyBytes));
    try {
      app = App.fromMap(map);
      return app;
    }catch (e){
      print("App error $e");
    }
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  }
}
Future<App> postApp({required User user, required App app}) async {


  final response = await http.put(
    Uri.parse('http://doubleplay.herokuapp.com/api/app/1/'),
    body: app.toMap(),
    headers: <String, String>{
      'Authorization': 'token ' + user.token!,
    },
  );
  print(response.statusCode);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> map ;
    App app;
    map = jsonDecode(utf8.decode(response.bodyBytes));
    try {
      app = App.fromMap(map);
      return app;
    }catch (e){
      print("App error $e");
    }
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('error on making request. ' + utf8.decode(response.bodyBytes));
  }
}
