library ecoinclution_proyect.global;
import 'dart:async';
import 'package:bolita_cubana/api_connection/apis.dart';
import 'package:bolita_cubana/models/disabled_bets.dart';
import 'package:bolita_cubana/models/models.dart';
import 'package:flutter/material.dart';
import '../filters/filters.dart';


enum ModelsStatus {
  updating,
  updated,
  error,
  needUser
}

class ModelOptions {
  bool hasMore = false;
  int page = 1;
  ModelOptions({required this.hasMore, required this.page});
}

class ModelsManager with ChangeNotifier {

  ModelsStatus status = ModelsStatus.updated;
  User user = User();

  List<User> users = [];
  User selectedUser = User();
  List<Play> plays = [];
  bool firstPlay = false;
  List<Padlock> padlocks = [];
  Padlock padlock = Padlock(id: 0,user: User());
  Play play = Play(padlock: Padlock(id: 0,user: User()));
  List<DisabledNumbers> disabledNumbers = [];
  List<DisabledBets> disabledBets = [];
  List<Collector> collectors = [];
  Collector selectedCollector = Collector(id: 0, listers:  [], name: "");
  App app = App(active: false, stopHour: TimeOfDay.now());

  bool showContinuePlayingDialog = false;

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
  Future<void> registerUser({String username = "", bool isSuperuser = false, bool isStaff = false, String password = "", String password2 = "",}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try {
      UserSignUp userSignUp = UserSignUp(username: username, isStaff: isStaff, isSuperuser: isSuperuser,password:password,password2:password2);
      Map<String,dynamic> map = await postUser(user: user, userSignUp: userSignUp);
    }catch (e){
      throw e;
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<ModelOptions> updateUsers({Filter? filter, bool loadMore = false, int page = 1}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "users",modelType: ModelType.user);
      fetchedModels = await modelsApi.getModels(filter: filter, page: page);
      if (loadMore){
        for (var model in fetchedModels.models){
          users.add(model as User);
        }
      }else {
        users = [];
        for (var model in fetchedModels.models){
          users.add(model as User);
        }
      }
    }catch (e){

      await updateUserStatus(e);
      print("updateUsers $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return ModelOptions(hasMore: fetchedModels.hasMore, page: page);
  }
  Future<void> updateUser({required User model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "users",modelType: ModelType.user);
      selectedUser = await modelsApi.putModel(id:model.id,model: model) as User;
    }catch (e){
      await updateUserStatus(e);
      print("updateUser $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<bool> removeUser({required User model}) async {
    bool sameUser = false;
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "users",modelType: ModelType.user);
      await modelsApi.deleteModel(id: model.id);
      if (user == model) {
        sameUser = true;
      }
    }catch (e){
      await updateUserStatus(e);
      print("removeUser $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return sameUser;
  }

  Future<ModelOptions> updatePlays({Filter? filter, bool loadMore = false, int page = 1}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",modelType: ModelType.play);
      fetchedModels = await modelsApi.getModels(filter: filter, page: page, modelTypeFr: ModelType.padlock, modelsFr: padlocks);
      if (loadMore){
        for (var model in fetchedModels.models){
          plays.add(model as Play);
        }
      }else {
        plays = [];
        for (var model in fetchedModels.models){
          plays.add(model as Play);
        }
      }
    }catch (e){
      plays = [];
      await updateUserStatus(e);
      print("updatePlays $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return ModelOptions(hasMore: fetchedModels.hasMore, page: page);
  }
  Future<void> updatePlay({required Play model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",modelType: ModelType.play);
      play = await modelsApi.putModel(id: model.id, model: model,modelsFr: padlocks, modelTypeFr: ModelType.padlock) as Play;
    }catch (e){
      await updateUserStatus(e);
      print("updatePlay $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> createPlay({required Play model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",modelType: ModelType.play);
      play = await modelsApi.postModel(model: model, modelsFr: padlocks, modelTypeFr: ModelType.padlock) as Play;
    }catch (e){
      await updateUserStatus(e);
      print("createPlay $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<bool> removePlay({required Play model}) async {
    bool sameUser = false;
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",modelType: ModelType.play);
      await modelsApi.deleteModel(id: model.id);
    }catch (e){
      await updateUserStatus(e);
      print("updatePlays $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return sameUser;
  }


  Future<ModelOptions> updatePadlocks({Filter? filter, bool loadMore = false, int page = 1,required User userFr,bool change = true}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: this.user.token, modelString: "padlocks",modelType: ModelType.padlock);
      fetchedModels = await modelsApi.getModels(filter: filter, page: page, modelTypeFr: ModelType.user, modelsFr: [userFr]);
      if (loadMore){
        for (var model in fetchedModels.models){
          padlocks.add(model as Padlock);
        }
      }else {
        padlocks = [];
        for (var model in fetchedModels.models){
          padlocks.add(model as Padlock);
        }

      }
    }catch (e) {
      padlocks = [];
      await updateUserStatus(e);
      print("updatePadlocks $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return ModelOptions(hasMore: fetchedModels.hasMore, page: page);
  }
  Future<void> createPadlock({required Padlock model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "padlocks",modelType: ModelType.padlock);
      padlock = await modelsApi.postModel(model: model,modelsFr: [user], modelTypeFr: ModelType.user) as Padlock;
      padlocks.add(padlock);
    }catch (e){
      await updateUserStatus(e);
      print("createPadlock $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> removePadlock({required Padlock model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "padlocks",modelType: ModelType.padlock);
      await modelsApi.deleteModel(id:model.id) ;
    }catch (e){
      await updateUserStatus(e);
      print("removePadlock $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> updatePadlock({required Padlock model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "padlocks",modelType: ModelType.padlock);
      this.padlock = await modelsApi.putModel(id: model.id, model: model,modelsFr: [user], modelTypeFr: ModelType.user) as Padlock;
      print(this.padlock.toUpdateMap());
    }catch (e){
      updateUserStatus(e);
      print("updatePadlock $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }

  Future<void> getApp() async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "app",modelType: ModelType.app);
      app = await modelsApi.getModel(id:1) as App;
    }catch (e){
      print("getApp $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> updateApp() async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "app",modelType: ModelType.app);
      app = await modelsApi.putModel(id:1,model: app) as App;
    }catch (e){
      print("updateApp $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
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
      await updateUserStatus(e);
      print("fetchUser $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }

  Future<void> updateDisabledNumbers() async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-numbers",modelType: ModelType.disabledNumbers);
      fetchedModels = await modelsApi.getModels();
      disabledNumbers = [];
      for (var model in fetchedModels.models){
        disabledNumbers.add(model as DisabledNumbers);
      }
    }catch (e){
      disabledNumbers = [];
      await updateUserStatus(e);
      print("updateDisabledNumbers $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> updateDisabledNumber({required DisabledNumbers model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-numbers",modelType: ModelType.disabledNumbers);
      disabledNumbers[model.id - 1] = await modelsApi.putModel(id:model.id,model: model) as DisabledNumbers;
    }catch (e){
      await updateUserStatus(e);
      print("updateDisabledNumber $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }

  Future<void> updateDisabledBets() async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-bets",modelType: ModelType.disabledBets);
      fetchedModels = await modelsApi.getModels();
      disabledBets = [];
      for (var model in fetchedModels.models){
        disabledBets.add(model as DisabledBets);
      }
    }catch (e){
      disabledBets = [];
      await updateUserStatus(e);
      print("updateDisabledBets $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> updateDisabledBet({required DisabledBets model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-bets",modelType: ModelType.disabledBets);
      disabledBets[model.id - 1] = await modelsApi.putModel(id:model.id,model: model) as DisabledBets;
    }catch (e){
      await updateUserStatus(e);
      print("updateDisabledBet $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }


  Future<ModelOptions> updateCollectors({Filter? filter, bool loadMore = false, int page = 1}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",modelType: ModelType.collector);
      fetchedModels = await modelsApi.getModels(filter: filter, page: page);
      if (loadMore){
        for (var model in fetchedModels.models){
          collectors.add(model as Collector);
        }
      }else {
        collectors = [];
        for (var model in fetchedModels.models){
          collectors.add(model as Collector);
        }
      }
    }catch (e){
      collectors = [];
      await updateUserStatus(e);
      print("updateCollectors $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return ModelOptions(hasMore: fetchedModels.hasMore, page: page);
  }
  Future<void> updateCollector({required Collector model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",modelType: ModelType.collector);
      selectedCollector = await modelsApi.putModel(id: model.id, model: model) as Collector;
    }catch (e){
      await updateUserStatus(e);
      print("updateCollector $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> createCollector({required Collector model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",modelType: ModelType.collector);
      selectedCollector = await modelsApi.postModel(model: model) as Collector;

    }catch (e){
      await updateUserStatus(e);
      print("createCollector $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> removeCollector({required Collector model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",modelType: ModelType.collector);
      await modelsApi.deleteModel(id: model.id);
    }catch (e){
      await updateUserStatus(e);
      print("removeCollector $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }

  void selectUser(User user){
    selectedUser = user;
  }
  void selectCollector(Collector collector){
    selectedCollector = collector;
  }

  Future<bool> isAppActive() async {
    await getApp();
    return app.active;
  }

  Future<bool> isUserActive() async {
    await fetchUser();
    return user.isActive;
  }

  Future<bool> isUserPlaying() async {
    await updatePadlocks(filter: PadlockFilter(user: user.id.toString()),userFr: user);
    for (var padlock in padlocks){
      if (padlock.playing){
        this.padlock = padlock;
        return true;
      }
    }
    return false;
  }

  Future<void> updateUserStatus(Object e) async {
    if (user.userStatus == UserStatus.authenticated) {
      if (e == Exceptions.forbidden) {
        if (!(user.isStaff || user.isSuperuser)) {
          user.userStatus = UserStatus.appNotActive;
        }
      } else if (e == Exceptions.unauthorized) {
        user.userStatus = UserStatus.unauthorized;
      }
    }
  }
}
