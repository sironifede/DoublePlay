library ecoinclution_proyect.global;
import 'dart:async';

import 'package:bolita_cubana/api_connection/apis.dart';
import 'package:bolita_cubana/models/models.dart';


import 'package:flutter/material.dart';

import '../../repository/user_repository.dart';
import '../filters/filter.dart';


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
  User? user;
  UserRepository userRepository = UserRepository();

  List<User> users = [];
  User? selectedUser;
  List<Play> plays = [];
  List<DisabledNumbers> disabledNumbers = [];
  App app = App(active: false, stopHour: TimeOfDay.now());


  Future<User> authenticateUser({required String username, required String password}) async {
    status = ModelsStatus.updating;
    notifyListeners();

    try {
      user = await userRepository.authenticateUser(
          username: username, password: password);
      status = ModelsStatus.updated;
      notifyListeners();
      return user!;
    }catch (e){
      status = ModelsStatus.updated;
      notifyListeners();
      throw e;
    }
  }
  Future<void> registerUser({
  String username = "",
  bool isSuperuser = false,
  bool isStaff = false,
  String password = "",
  String password2 = "",
  }) async {
    status = ModelsStatus.updating;
    notifyListeners();
    try {
      await userRepository.registerUser(user: user!, username: username, isStaff: isStaff, isSuperuser: isSuperuser,password:password,password2:password2);
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
    FetchedUsers fetchedUsers = FetchedUsers(models: [], hasMore: false);
    try{
      fetchedUsers = await fetchUsers(user: user!, filter: filter, page: page);
      if (loadMore){
        users.addAll(fetchedUsers.models);
      }else {
        users = fetchedUsers.models;
      }
    }catch (e){
      print("updateUsers $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return ModelOptions(hasMore: fetchedUsers.hasMore, page: page);
  }
  Future<ModelOptions> updatePlays({Filter? filter, bool loadMore = false, int page = 1}) async {
    status = ModelsStatus.updating;
    notifyListeners();
    FetchedPlays fetchedPlays = FetchedPlays(models: [], hasMore: false);
    try{
      fetchedPlays = await fetchPlays(user: user!, filter: filter, page: page);
      if (loadMore){
        plays.addAll(fetchedPlays.models);
      }else {
        plays = fetchedPlays.models;
      }
    }catch (e){
      print("updatePlays $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
    return ModelOptions(hasMore: fetchedPlays.hasMore, page: page);
  }
  Future<bool> removeUser({required User userToDelete}) async {
    bool sameUser = false;
    status = ModelsStatus.updating;
    notifyListeners();
    try{

      await deleteUser(user: user!, userToDelete: userToDelete);
      if (user! == userToDelete) {
        sameUser = true;
      }
    }catch (e){
      print("removeUser $e");
    }

    status = ModelsStatus.updated;
    notifyListeners();
    return sameUser;
  }

  Future<void> getApp() async {
    status = ModelsStatus.updating;
    notifyListeners();
    try{
      app = await fetchApp(user: user!);
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
      app = await postApp(user: user!, app: app);
    }catch (e){
      print("updateApp $e");
    }
    status = ModelsStatus.updated;
    notifyListeners();
  }



  Future<void> updateUser() async {
    status = ModelsStatus.updating;
    notifyListeners();
    user = await userRepository.getUser(id: 0);
    String token = user!.token!;
    user = await getUser(user: user!);
    user!.token = token;
    status = ModelsStatus.updated;
    notifyListeners();
  }

  void selectUser(User user){
    selectedUser = user;
  }

  Future<void> updateAll() async {
    try {
      await updateUser();
      await updateUsers();
    } catch (e) {
      print("There is no user$e");
    }
  }
}

UserRepository userRepository = UserRepository();