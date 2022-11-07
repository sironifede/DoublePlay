import 'Model.dart';

class User  extends Model{
  int? id;
  String username;
  String? email;
  String? token;
  bool isSuperuser;
  bool isStaff;
  bool isActive;
  DateTime? dateJoined;
  DateTime? lastLogin;

  User(
      {this.id,
        this.email,
        this.token,
        this.username = "",
        this.isSuperuser = false,
        this.isStaff = false,
        this.isActive = false,
        this.dateJoined,
        this.lastLogin,
      });

  // factory User.fromMap(Map<String, dynamic> data) => User(
  //     id: data['id'],
  //     username: data['email'],
  //     token: data['token'],
  // );
  Map<String, dynamic> toMapDB() {
    return {
      "id": 0,
      "user_id": id,
      "username": username,
      "token": token,
    };
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "token": token,
      "is_staff": isStaff.toString(),
      "is_active": isActive.toString(),
      "is_superuser": isSuperuser.toString(),
    };
  }

  factory User.fromMapDB(Map<String, dynamic> data) {

    return User(
      id: data["user_id"],
      username: data["username"],
      email: data["email"],
      token: data["token"],
      isActive: (data["is_active"] == 1)?true: false,
      isSuperuser: (data["is_superuser"] == 1)?true: false,
      isStaff: (data["is_staff"] == 1)?true: false,
    );
  }
  factory User.fromMap(Map<String, dynamic> data){
    String dateJoinedStr = (data["date_joined"] == null)? "": data["date_joined"];
    String lastLoginDate = (data["last_login"] == null)? "": data["last_login"];
    DateTime? dateJoined = (data["date_joined"] == null )? null :DateTime.utc(int.parse(dateJoinedStr.split("-")[0]),int.parse(dateJoinedStr.split("-")[1]),int.parse(dateJoinedStr.split("-")[2].split("T")[0]),int.parse(dateJoinedStr.split("-")[2].split("T")[1].split(":")[0]),int.parse(dateJoinedStr.split("-")[2].split("T")[1].split(":")[1]),int.parse(dateJoinedStr.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll("Z", "")));
    DateTime? lastLogin = (data["last_login"] == null )?null: DateTime.utc(int.parse(lastLoginDate.split("-")[0]),int.parse(lastLoginDate.split("-")[1]),int.parse(lastLoginDate.split("-")[2].split("T")[0]),int.parse(lastLoginDate.split("-")[2].split("T")[1].split(":")[0]),int.parse(lastLoginDate.split("-")[2].split("T")[1].split(":")[1]),int.parse(lastLoginDate.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll("Z", "")));
    return User(
      id: data["id"],
      username: data["username"],
      email: data["email"],
      isActive: data["is_active"],
      isSuperuser: data["is_superuser"] ,
      isStaff: data["is_staff"],
      dateJoined: dateJoined,
      lastLogin:lastLogin,
    );
  }
}
