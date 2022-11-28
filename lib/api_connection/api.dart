import 'package:bolita_cubana/models/models.dart';
import 'package:http/http.dart' as http;
import '../filters/filter.dart';
import 'dart:convert';

class FetchedModels {

  List<Model> models = [];
  bool hasMore = false;

  FetchedModels({required this.models, required this.hasMore});
}

enum Exceptions{
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

  Future<FetchedModels> getModels({Filter? filter,int page = 1,List<Model>? modelsFr, ModelType? modelTypeFr}) async {
    print("getModels: $modelString");
    bool makeRequest = false;
    if (modelsFr == null ){
      makeRequest = true;
    }else{
      if (modelsFr.isNotEmpty) {
        makeRequest = true;
      }
    }
    if (makeRequest){
      final response = await http.get(
        Uri.parse('$uri$modelString/${(filter != null) ? filter
                .getFilterStr() + "page=$page" : "?page=$page"}'),
        headers: <String, String>{
          'Authorization': 'token $token',
        },
      );
      if (response.statusCode == 401){
        throw Exceptions.unauthorized;
      }
      if (response.statusCode == 403){
        throw Exceptions.forbidden;
      }
      if (response.statusCode == 400){
        throw Exceptions.badRequest;
      }
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        Map listMap;
        List<Model> list = [];
        bool hasMore = false;

        listMap = jsonDecode(utf8.decode(response.bodyBytes));
        if (listMap["next"] != null) {
          hasMore = true;
        }

        for (var row in listMap["results"]) {
          Model? model;
          if (modelsFr != null){
            Model? modelFrk;
            for (modelFrk in modelsFr) {
              if (modelFrk.id == row[modelTypeFr!.name]) {
                if (modelTypeFr == ModelType.padlock){
                  model = Model.fromMap(row,modelType, padlock: modelFrk as Padlock);
                }
                if (modelTypeFr == ModelType.user){
                  model = Model.fromMap(row,modelType, user: modelFrk as User);
                }
                break;
              }
            }
          }else{
            model = Model.fromMap(row,modelType);
          }
          if (model != null){
            list.add(model);
          }
        }
        return FetchedModels(models: list, hasMore: hasMore);
      }
      return FetchedModels(models: [], hasMore: false);
    }else{
      return FetchedModels(models: [], hasMore: false);
    }
  }

  Future<Model> getModel({required int id,List<Model>? modelsFr, ModelType? modelTypeFr}) async {

    final response = await http.get(
      Uri.parse('$uri$modelString/$id/'),
      headers: <String, String>{
        'Authorization': 'token $token',
      },
    );
    print("getModel: $modelString ,code: ${response.statusCode}");
    if (response.statusCode == 401){
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403){
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400){
      throw Exceptions.badRequest;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
      Model? model;
      if (modelsFr != null){
        Model? modelFrk;
        for (modelFrk in modelsFr) {
          if (modelFrk.id == map[modelTypeFr!.name]) {
            if (modelTypeFr == ModelType.padlock){
              model = Model.fromMap(map,modelType, padlock: modelFrk as Padlock);
            }
            if (modelTypeFr == ModelType.user){
              model = Model.fromMap(map,modelType, user: modelFrk as User);
            }
            break;
          }
        }

      }else{
        model = Model.fromMap(map,modelType);
      }
      return model!;
    }else{
      throw Exceptions.badRequest;
    }
  }

  Future<Model> postModel({required Model model,List<Model>? modelsFr, ModelType? modelTypeFr}) async {

    final response = await http.post(
      Uri.parse('$uri$modelString/'),
      body: model.toCreateMap(),
      headers: <String, String>{
        'Authorization': 'token $token',
      },
    );
    print("postModel: $modelString ,code: ${response.statusCode}");

    if (response.statusCode == 401){
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403){
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400){
      Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
      print(map);
      throw Exceptions.badRequest;
    }

    if (response.statusCode == 201) {
      Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
      Model? model;
      if (modelsFr != null){
        for (var modelFrk in modelsFr) {

          if (modelFrk.id == map[modelTypeFr!.name]) {
            if (modelTypeFr == ModelType.padlock){
              model = Model.fromMap(map,modelType, padlock: modelFrk as Padlock);
            }
            if (modelTypeFr == ModelType.user){
              model = Model.fromMap(map,modelType, user: modelFrk as User);
            }
            break;
          }
        }
      }else{
        model = Model.fromMap(map,modelType);
      }
      return model!;
    }else{
      throw Exceptions.badRequest;
    }
  }

  Future<Model> putModel({required int id, required Model model,List<Model>? modelsFr, ModelType? modelTypeFr}) async {
    final response = await http.put(
      Uri.parse('$uri$modelString/$id/'),
      body: model.toUpdateMap(),
      headers: {
        'Authorization': 'token $token',
      },
    );
    Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
    print(map);
    print("putModel: $modelString ,code: ${response.statusCode}");
    if (response.statusCode == 401){
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403){
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400){
      throw Exceptions.badRequest;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(utf8.decode(response.bodyBytes));
      Model? model;
      if (modelsFr != null){
        Model? modelFrk;
        for (modelFrk in modelsFr) {
          print("id: ${modelFrk.id}");
          print("map: ${map[modelTypeFr!.name]}");
          if (modelFrk.id == map[modelTypeFr.name]) {

            if (modelTypeFr == ModelType.padlock){
              model = Model.fromMap(map,modelType, padlock: modelFrk as Padlock);
            }
            if (modelTypeFr == ModelType.user){
              model = Model.fromMap(map,modelType, user: modelFrk as User);
            }
            break;
          }
        }

      }else{
        model = Model.fromMap(map,modelType);
      }
      return model!;
    }else{
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
    print("deleteModel: $modelString ,code: ${response.statusCode}");
    if (response.statusCode == 401){
      throw Exceptions.unauthorized;
    }
    if (response.statusCode == 403){
      throw Exceptions.forbidden;
    }
    if (response.statusCode == 400){
      throw Exceptions.badRequest;
    }

  }

}