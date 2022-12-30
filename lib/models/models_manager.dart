import 'dart:async';
import 'package:bolita_cubana/api_connection/apis.dart';
import 'package:bolita_cubana/models/models.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';
import '../filters/filters.dart';


enum ModelsStatus {
  updating,
  updated,
  error,
  needUser
}

class ModelOptions {
  FetchedModels fetchedModels;
  int page = 1;
  bool hasError = false;
  ModelOptions({required this.fetchedModels, required this.page, required this.hasError});
}

class ModelsManager with ChangeNotifier {

  ModelsStatus status = ModelsStatus.updated;
  bool newPlay = false;

  User user = User();
  User? selectedUser;
  Padlock? selectedPadlock;
  Play? selectedPlay;
  Collector? selectedCollector;

  App app = App(active: false, stopHour: TimeOfDay.now(), stopHour2: TimeOfDay.now());

  List<User> users = [];
  List<Collector> collectors = [];
  List<Padlock> padlocks = [];
  List<Play> plays = [];
  List<DisabledNumbers> disabledNumbers = [];
  List<DisabledBets> disabledBets = [];
  List<Month> months = [];
  List<Help> helps = [];

  Future<User> authenticateUser({required String username, required String password}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try {
      UserLogin userLogin = UserLogin(username: username, password: password);
      Token token = await getToken(userLogin);
      user = User(
        username: username,
        token: token.token, isSuperuser: false, isStaff: false, isActive: true,
      );
      user.userStatus = UserStatus.authenticated;
      await fetchUser();
      print(user.userStatus);
      if (user.userStatus == UserStatus.appNotActive) {

        throw "App not active";
      }
      user.userStatus = UserStatus.authenticated;
    }catch (e){

      status = ModelsStatus.updated;
      notifyListeners();
      throw e;
    }

    status = ModelsStatus.updated;
    notifyListeners();
    return user;
  }


  Future<Map<String,dynamic>> changePassword({required int id, String password = "", String password2 = "",}) async {
    Map<String,dynamic> map = {};
    status = ModelsStatus.updating;
    notifyListeners();
    try {
      UserPassword userPassword = UserPassword(id: id,password:password,password2:password2);
      map = await changeUserPassword(user:user,userPassword: userPassword);

    }catch (e){
      throw e;
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return map;
  }
  Future<Map<String,dynamic>> changeUsername({required User model}) async {
    Map<String,dynamic> map = {};
    status = ModelsStatus.updating;
    notifyListeners();
    try {
      map = await changeUserUsername(user: user,selectedUser: model);
    }catch (e){
      throw e;
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return map;
  }

  Future<Map<String,dynamic>> registerUser({String username = "", bool isSuperuser = false, bool isStaff = false, String password = "", String password2 = "",}) async {
    Map<String,dynamic> map = {};
    status = ModelsStatus.updating;
    notifyListeners();
    try {
      UserSignUp userSignUp = UserSignUp(username: username, isStaff: isStaff, isSuperuser: isSuperuser,password:password,password2:password2);
      map = await postUser(user: user, userSignUp: userSignUp);

    }catch (e){
      throw e;
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return map;
  }

  Future<ModelOptions> updateModels({Filter? filter, int page = 1,List<int>? newList , required ModelType modelType}) async {
    String modelString = "users";
    List<Model> models = users;
    switch(modelType){
      case ModelType.user:
        models = users;
        modelString = "users";
        break;
      case ModelType.padlock:
        models = padlocks;
        modelString = "padlocks";
        break;
      case ModelType.month:
        models = months;
        modelString = "months";
        break;
      case ModelType.collector:
        models = collectors;
        modelString = "collectors";
        break;
      case ModelType.play:
        models = plays;
        modelString = "plays";
        break;
      case ModelType.disabledBets:
        models = disabledBets;
        modelString = "disabled-bets";
        break;
      case ModelType.disabledNumbers:
        models = disabledNumbers;
        modelString = "disabled-numbers";
        break;
      case ModelType.app:
        modelString = "app";
        break;
      case ModelType.help:
        models = helps;
        modelString = "helps";
        break;
    }

    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    bool hasError = false;
    try{
      if (filter != null){
        if (newList != null){
          for (var model in models){
            if (newList.contains(model.id)){
              newList.remove(model.id);
            }
          }
          if (modelType == ModelType.collector){
            filter.idIn = ValueInFilterField(fieldName: "user_id__in");
          }
          filter.idIn.values = newList;
        }
      }
      bool makeRequest = true;
      if (newList != null){
        if (newList.isEmpty){
          makeRequest = false;
        }
      }
      if (makeRequest) {


        ModelsApi modelsApi = ModelsApi(
            token: user.token, modelString: modelString, modelType: modelType);
        fetchedModels = await modelsApi.getModels(filter: filter, page: page);
      }
      List<int> lastIds = [];
      for (var model in models){
        lastIds.add(model.id);
      }
      for (var newModel in fetchedModels.models){
        bool add = true;
        for (var i = 0; i < models.length; i++){
          if (newModel.id == models[i].id){
            models[i]  = newModel;
            add = false;
            break;
          }
        }
        if (add){
          models.add(newModel);
        }
      }
    }catch (e){
      updateUser(e);
      hasError = true;
      print("fallo todo $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return ModelOptions(fetchedModels: fetchedModels, page: page, hasError: hasError);
  }
  Future<Model> getModel({required ModelType modelType, required Model model}) async {
    String modelString = "users";
    List<Model> models = users;
    switch(modelType){
      case ModelType.user:
        models = users;
        modelString = "users";
        break;
      case ModelType.padlock:
        models = padlocks;
        modelString = "padlocks";
        break;
      case ModelType.month:
        models = months;
        modelString = "months";
        break;
      case ModelType.collector:
        models = collectors;
        modelString = "collectors";
        break;
      case ModelType.play:
        models = plays;
        modelString = "plays";
        break;
      case ModelType.disabledBets:
        models = disabledBets;
        modelString = "disabled-bets";
        break;
      case ModelType.disabledNumbers:
        models = disabledNumbers;
        modelString = "disabled-numbers";
        break;
      case ModelType.app:
        modelString = "app";
        break;
      case ModelType.help:
        models = helps;
        modelString = "helps";
        break;
    }
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: modelString,modelType: modelType);
      model = await modelsApi.getModel(id: model.id);
    }catch (e){
      updateUser(e);
      print("fallo todo $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return model;
  }

  Future<Model> updateModel({required ModelType modelType, required Model model}) async {
    String modelString = "users";
    List<Model> models = users;
    switch(modelType){
      case ModelType.user:
        models = users;
        modelString = "users";
        break;
      case ModelType.padlock:
        models = padlocks;
        modelString = "padlocks";
        break;
      case ModelType.month:
        models = months;
        modelString = "months";
        break;
      case ModelType.collector:
        models = collectors;
        modelString = "collectors";
        break;
      case ModelType.play:
        models = plays;
        modelString = "plays";
        break;
      case ModelType.disabledBets:
        models = disabledBets;
        modelString = "disabled-bets";
        break;
      case ModelType.disabledNumbers:
        models = disabledNumbers;
        modelString = "disabled-numbers";
        break;
      case ModelType.app:
        modelString = "app";
        break;
      case ModelType.help:
        models = helps;
        modelString = "helps";
        break;
    }
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: modelString,modelType: modelType);
      model = await modelsApi.putModel(model: model);
    }catch (e){
      updateUser(e);
      print("fallo todo $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return model;
  }

  Future<Model> createModel({ required ModelType modelType,required Model model}) async {
    String modelString = "users";
    List<Model> models = users;
    switch(modelType){
      case ModelType.user:
        models = users;
        modelString = "users";
        break;
      case ModelType.padlock:
        models = padlocks;
        modelString = "padlocks";
        break;
      case ModelType.month:
        models = months;
        modelString = "months";
        break;
      case ModelType.collector:
        models = collectors;
        modelString = "collectors";
        break;
      case ModelType.play:
        models = plays;
        modelString = "plays";
        break;
      case ModelType.disabledBets:
        models = disabledBets;
        modelString = "disabled-bets";
        break;
      case ModelType.disabledNumbers:
        models = disabledNumbers;
        modelString = "disabled-numbers";
        break;
      case ModelType.app:
        break;
      case ModelType.help:
        models = helps;
        modelString = "helps";
        break;
    }
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: modelString,modelType: modelType);
      model = await modelsApi.postModel(model: model);
      models.add(model);
    }catch (e){
      updateUser(e);
      print("fallo todo $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return model;
  }

  Future<void> removeModel({ required ModelType modelType, required Model model}) async {
    String modelString = "users";
    List<Model> models = users;
    switch(modelType){
      case ModelType.user:
        models = users;
        modelString = "users";
        break;
      case ModelType.padlock:
        models = padlocks;
        modelString = "padlocks";
        break;
      case ModelType.month:
        models = months;
        modelString = "months";
        break;
      case ModelType.collector:
        models = collectors;
        modelString = "collectors";
        break;
      case ModelType.play:
        models = plays;
        modelString = "plays";
        break;
      case ModelType.disabledBets:
        models = disabledBets;
        modelString = "disabled-bets";
        break;
      case ModelType.disabledNumbers:
        models = disabledNumbers;
        modelString = "disabled-numbers";
        break;
      case ModelType.app:
        break;
      case ModelType.help:
        models = helps;
        modelString = "helps";
        break;
    }
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: modelString,modelType: modelType);
      await modelsApi.deleteModel(id: model.id);
      models.remove(model);
    }catch (e){
      updateUser(e);
      print("fallo todo $e");
    }

    status = ModelsStatus.updated;
    notifyListeners();

  }
  void updateUser(e){
    switch(e){
      case Exceptions.forbidden:
        user.userStatus = UserStatus.appNotActive;
        break;
      case Exceptions.unauthorized:
        user.userStatus = UserStatus.unauthorized;
        break;
      case Exceptions.badRequest:
        user.userStatus = UserStatus.authenticated;
        break;
      default:
        user.userStatus = UserStatus.authenticated;
        break;
    }
  }

  Future<void> fetchUser() async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      String token = user.token;
      user = await getUser(user: user);
      user.token = token;
      user.userStatus = UserStatus.authenticated;
    }catch (e) {
      //await updateUserStatus(e);
      print("fetchUser $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
}
