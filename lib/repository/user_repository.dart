import 'dart:async';
import 'package:bolita_cubana/models/user_signup.dart';
import '../api_connection/auth/api_connection.dart';
import '../dao/user.dart';
import '../models/user.dart';
import '../models/user_login.dart';

class UserRepository {
  final userDao = UserDao();
  Future<Map<String,dynamic>> registerUser({
    required User user,
    String username = "",
    bool isSuperuser = false,
    bool isStaff = false,
    String password = "",
    String password2 = "",
  }) async {
    UserSignUp userRegister = UserSignUp(username: username, password: password, password2: password2, isSuperuser: isSuperuser, isStaff: isStaff);
    Map<String,dynamic> map = await postUser(user: user, userSignUp: userRegister);
    return map;
  }

  Future<User> authenticateUser({
    String username = "",
    String password = "",
  }) async {
    UserLogin userLogin = UserLogin(username: username, password: password);
    Token token = await getToken(userLogin);
    User user = User(
      username: username,
      token: token.token, isSuperuser: false, isStaff: false, isActive: true,
    );
    print(user);
    return user;
  }

  Future<void> persistToken({required User? user}) async {
    // write token with the user to the database
    int result = await userDao.createUser(user!);
    print("id $result created");
  }
  Future<void> updateUser({required User? user}) async {
    // write token with the user to the database
    int result = await userDao.updateUser(user!);
    print(user.toMapDB());
    print("id $result updated");
  }

  Future<void> deleteToken({required int? id}) async {
    int result = await userDao.deleteUser(id);
    print("id $result deleted");
  }

  Future<bool> hasToken({required int? id}) async {
    bool result = await userDao.checkUser(id);
    return result;
  }

  Future<User> getUser({required int? id}) async {
    Map<String, dynamic> map = await userDao.selectUser(id);
    User user = User.fromMapDB(map);
    return user;
  }
}
