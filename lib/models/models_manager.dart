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

  bool showActiveAppDialog = false;
  bool showContinuePlayingDialog = false;
  bool showedActiveAppDialog = false;

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
      await fetchUser();
      if (!(user.isStaff || user.isSuperuser)) {
        await getApp();
        if (!app.active) {
          showActiveAppDialog = true;
          throw Exception("App is not active");
        }
      }
    }catch (e){
      print(e);
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
      status = ModelsStatus.updated;
      notifyListeners();
    }catch (e){
      status = ModelsStatus.updated;
      notifyListeners();
      throw e;
    }
  }
  Future<ModelOptions> updateUsers({Filter? filter, bool loadMore = false, int page = 1}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "users",models: Models.user);
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
        //users = fetchedModels.models as List<User>;
      }
    }catch (e){
      users = [];
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "users",models: Models.user);
      selectedUser = await modelsApi.putModel(id:model.id,model: model) as User;
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "users",models: Models.user);
      await modelsApi.deleteModel(id: model.id);
      if (user == model) {
        sameUser = true;
      }
    }catch (e){
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",models: Models.play);
      fetchedModels = await modelsApi.getModels(filter: filter, page: page, modelFr: Models.padlock, modelsFr: padlocks);
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
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",models: Models.play);
      play = await modelsApi.putModel(id: model.id, model: model,modelsFr: padlocks, modelFr: Models.padlock) as Play;
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
      print("updatePlay $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> createPlay({required Play model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",models: Models.play);
      play = await modelsApi.postModel(model: model, modelsFr: padlocks, modelFr: Models.padlock) as Play;
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "plays",models: Models.play);
      await modelsApi.deleteModel(id: model.id);
    }catch (e){
      print("updatePlays $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return sameUser;
  }


  Future<ModelOptions> updatePadlocks({Filter? filter, bool loadMore = false, int page = 1, User? user,bool change = true}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: this.user.token, modelString: "padlocks",models: Models.padlock);
      if (user == null){
        fetchedModels = await modelsApi.getModels(filter: PadlockFilter(user:this.user.id.toString()), page: page, modelFr: Models.user, modelsFr: [this.user]);
        padlocks = [];
        for (var model in fetchedModels.models){
          padlocks.add(model as Padlock);
        }
        for (var i in padlocks){
          if (i.playing){
            padlock = i;
            await updatePlays(filter: PlayFilter(padlock: i.id.toString()));
            for (var j in plays){
              if (!j.confirmed){
                play = j;

                break;
              }
            }

            if (change){
              showContinuePlayingDialog = true;
            }
            break;
          }
        }
      }else{
        fetchedModels = await modelsApi.getModels(filter: filter, page: page, modelFr: Models.user, modelsFr: [user]);
        if (loadMore){
          for (var model in fetchedModels.models){
            padlocks.add(model as Padlock);
          }
        }else {
          padlocks = [];
          for (var model in fetchedModels.models){
            print(model.id);
            padlocks.add(model as Padlock);
          }

        }
      }

    }catch (e) {
      padlocks = [];
      if (!(this.user.isStaff || this.user.isSuperuser)) {
        await getApp();
        if (!app.active) {
          showActiveAppDialog = true;
        }
      }
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "padlocks",models: Models.padlock);
      padlock = await modelsApi.postModel(model: model,modelsFr: [user], modelFr: Models.user) as Padlock;
      padlocks.add(padlock);
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
      print("createPadlock $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> updatePadlock({required Padlock model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "padlocks",models: Models.padlock);
      this.padlock = await modelsApi.putModel(id: model.id, model: model,modelsFr: [user], modelFr: Models.user) as Padlock;
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
      print("updatePadlock $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }

  Future<void> getApp() async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "app",models: Models.app);
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "app",models: Models.app);
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
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
          throw Exception("App is not active");
        }
      }
      throw e;
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }

  Future<void> updateDisabledNumbers() async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedModels fetchedModels = FetchedModels(models: [], hasMore: false);
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-numbers",models: Models.disabledNumbers);
      fetchedModels = await modelsApi.getModels();
      disabledNumbers = [];
      for (var model in fetchedModels.models){
        disabledNumbers.add(model as DisabledNumbers);
      }
    }catch (e){
      disabledNumbers = [];
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
      print("updateDisabledNumbers $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> updateDisabledNumber({required DisabledNumbers model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-numbers",models: Models.disabledNumbers);
      disabledNumbers[model.id - 1] = await modelsApi.putModel(id:model.id,model: model) as DisabledNumbers;
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-bets",models: Models.disabledBets);
      fetchedModels = await modelsApi.getModels();
      disabledBets = [];
      for (var model in fetchedModels.models){
        disabledBets.add(model as DisabledBets);
      }
    }catch (e){
      disabledBets = [];
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
      print("updateDisabledBets $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> updateDisabledBet({required DisabledBets model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "disabled-bets",models: Models.disabledBets);
      disabledBets[model.id - 1] = await modelsApi.putModel(id:model.id,model: model) as DisabledBets;
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",models: Models.collector);
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
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
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
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",models: Models.collector);
      selectedCollector = await modelsApi.putModel(id: model.id, model: model) as Collector;
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
      print("updateCollector $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> createCollector({required Collector model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",models: Models.collector);
      selectedCollector = await modelsApi.postModel(model: model) as Collector;

    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
      print("createCollector $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }
  Future<void> removeCollector({required Collector model}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      ModelsApi modelsApi = ModelsApi(token: user.token, modelString: "collectors",models: Models.collector);
      await modelsApi.deleteModel(id: model.id);
    }catch (e){
      if (!(user.isStaff || user.isSuperuser)){
        await getApp();
        if (!app.active){
          showActiveAppDialog = true;
        }
      }
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

}
