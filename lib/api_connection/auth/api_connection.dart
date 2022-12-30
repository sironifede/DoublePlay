import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import '../../models/user_login.dart';
import '../../models/user_signup.dart';

final _base = "https://doubleplay.herokuapp.com";
final _tokenEndpoint = "/api-token-auth/";
final _tokenURL = _base + _tokenEndpoint;
final Uri tokenUri = Uri.parse(_tokenURL);

Future<Token> getToken(UserLogin userLogin) async {
  print(_tokenURL);
  final http.Response response = await http.post(
    tokenUri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(userLogin.toJson()),
  );
  print("request made /api_conection/");
  if (response.statusCode == 200) {
    print(utf8.decode(response.bodyBytes));
    return Token.fromJson(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    print(" Error ${response.statusCode} ");
    print(json.decode(utf8.decode(response.bodyBytes)));
    throw json.decode(utf8.decode(response.bodyBytes));
  }
}
final _registerEndpoint = "/api/register/";
final _registerURL = _base + _registerEndpoint;
final Uri _registerUri = Uri.parse(_registerURL);

Future<Map<String,dynamic>> postUser({required User user,required UserSignUp userSignUp}) async {
  print(_registerURL);
  final http.Response response = await http.post(
    _registerUri,
    headers: <String, String>{
      'Authorization': 'token ${user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(userSignUp.toJson()),
  );

  print("request made ${userSignUp.toJson()} /api_conection/");
  if (response.statusCode == 201) {
    print(utf8.decode(response.bodyBytes));
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    print("error ${response.statusCode} /api_conection/");
    throw json.decode(utf8.decode(response.bodyBytes));
  }
}

final _changeEndpoint = "/api/change_password/";
final _changeURL = _base + _changeEndpoint;


Future<Map<String,dynamic>> changeUserPassword({required User user,required UserPassword userPassword}) async {
  print(_changeURL);
  final http.Response response = await http.put(
    Uri.parse("$_changeURL${userPassword.id}/"),
    headers: <String, String>{
      'Authorization': 'token ${user.token}',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(userPassword.toJson()),
  );

  print("request made ${userPassword.toJson()} , response: ${response.body}, uri: ${response.request!.url}");
  if (response.statusCode == 200) {
    print(utf8.decode(response.bodyBytes));
    return json.decode(utf8.decode(response.bodyBytes));
  } else {
    print("error ${response.statusCode}");
    throw json.decode(utf8.decode(response.bodyBytes));
  }
}

Future<Map<String,dynamic>> changeUserUsername({required User user, required User selectedUser}) async {
  final response = await http.put(
    Uri.parse(_base + '/api/users/${selectedUser.id}/'),
    body: selectedUser.toUpdateMap(),
    headers: {
      'Authorization': 'token ${user.token}',
    },
  );

  print("putModel: users ,code: ${response.statusCode}, response:${response.body}");

  if (response.statusCode == 200) {
    Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));

    return map;
  }else{
    print(json.decode(utf8.decode(response.bodyBytes)));
    throw json.decode(utf8.decode(response.bodyBytes));
  }
}