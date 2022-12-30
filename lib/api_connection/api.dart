import 'package:bolita_cubana/models/models.dart';
import 'package:http/http.dart' as http;
import '../filters/filter.dart';
import 'dart:convert';

class FetchedModels {
  List<Model> models = [];
  bool hasMore = false;

  FetchedModels({required this.models, required this.hasMore});
}

enum Exceptions {
  unauthorized,
  forbidden,
  badRequest,
}

class ModelsApi {
  String uri = 'http://doubleplay.herokuapp.com/api/';
  String modelString;
  String token;
  ModelType modelType;

  ModelsApi({
    required this.modelString,
    required this.token,
    required this.modelType,
  });

  Future<FetchedModels> getModels({Filter? filter, int page = 1}) async {
    final response = await http.get(
      Uri.parse(
          '$uri$modelString/${(filter != null) ? filter.getFilterStr() + "page=$page" : "?page=$page"}'),
      headers: <String, String>{
        'Authorization': 'token $token',
      },
    );

    print("getModels: $modelString ,code: ${response.statusCode}, response:${response.body}");

    if (response.statusCode == 401) {
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403) {
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400) {
      throw Exceptions.badRequest;
    }

    if (response.statusCode == 200) {
      Map listMap;
      List<Model> list = [];
      bool hasMore = false;
      listMap = jsonDecode(utf8.decode(response.bodyBytes));
      if (listMap["next"] != null) {
        hasMore = true;
      }

      for (var row in listMap["results"]) {
        list.add(Model.fromMap(row, modelType));
      }
      return FetchedModels(models: list, hasMore: hasMore);
    }
    return FetchedModels(models: [], hasMore: false);
  }

  Future<Model> getModel({required int id}) async {
    final response = await http.get(
      Uri.parse('$uri$modelString/$id/'),
      headers: <String, String>{
        'Authorization': 'token $token',
      },
    );
    print("getModel: $modelString ,code: ${response.statusCode}, response:${response.body}");
    if (response.statusCode == 401) {
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403) {
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400) {
      throw Exceptions.badRequest;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
      return Model.fromMap(map, modelType);
    } else {
      throw Exceptions.badRequest;
    }
  }

  Future<Model> postModel({required Model model}) async {
    final response = await http.post(
      Uri.parse('$uri$modelString/'),
      body: model.toCreateMap(),
      headers: <String, String>{
        'Authorization': 'token $token',
      },
    );

    print("postModel: $modelString ,code: ${response.statusCode}, response:${response.body}");

    if (response.statusCode == 401) {
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403) {
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400) {
      throw Exceptions.badRequest;
    }

    if (response.statusCode == 201) {
      Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
      return Model.fromMap(map, modelType);
    } else {
      throw Exceptions.badRequest;
    }
  }

  Future<Model> putModel({ required Model model}) async {
    final response = await http.put(
      Uri.parse('$uri$modelString/${model.id}/'),
      body: model.toUpdateMap(),
      headers: {
        'Authorization': 'token $token',
      },
    );

    print("putModel: $modelString ,code: ${response.statusCode}, response:${response.body}");

    if (response.statusCode == 401) {
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403) {
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400) {
      throw Exceptions.badRequest;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
      return Model.fromMap(map, modelType);
    } else {
      throw Exceptions.badRequest;
    }
  }

  Future<void> deleteModel({required int id}) async {

    final response = await http.delete(
      Uri.parse('$uri$modelString/$id/'),
      headers: <String, String>{
        'Authorization': 'token $token',
      },
    );

    print("deleteModel: $modelString ,code: ${response.statusCode}, response:${response.body}");

    if (response.statusCode == 401) {
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403) {
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400) {
      throw Exceptions.badRequest;
    }
  }
}
