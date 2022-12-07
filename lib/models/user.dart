import 'model.dart';

enum UserStatus {
  unauthenticated,
  authenticated,
  unauthorized,
  appNotActive

}

class User  extends Model{
  String username;
  String? email;
  String token;
  bool isSuperuser;
  bool isStaff;
  bool isActive;
  bool isCollector;
  DateTime? dateJoined;
  DateTime? lastLogin;
  UserStatus userStatus;


  User(
      {
        int id = 0,
        this.email,
        this.token = "",
        this.username = "",
        this.isSuperuser = false,
        this.isStaff = false,
        this.isActive = true,
        this.isCollector = false,
        this.dateJoined,
        this.lastLogin,
        this.userStatus = UserStatus.unauthenticated
      }):super(id: id);

  Map<String, dynamic> toMapDB() {
    return {
      "id": 0,
      "user_id": id,
      "username": username,
      "token": token,
    };
  }
  @override
  Map<String, dynamic> toUpdateMap() {
    return {
      "id": id.toString(),
      "username": username.toString(),
      "email": email.toString(),
      "is_staff": isStaff.toString(),
      "is_active": isActive.toString(),
      //"is_superuser": isSuperuser.toString(),
    };
  }

  factory User.fromMap(Map<String, dynamic> data) {
    String dateJoinedStr = (data["date_joined"] == null)? "": data["date_joined"];
    String lastLoginDate = (data["last_login"] == null)? "": data["last_login"];
    DateTime? dateJoined = (data["date_joined"] == null )? null :DateTime.utc(int.parse(dateJoinedStr.split("-")[0]),int.parse(dateJoinedStr.split("-")[1]),int.parse(dateJoinedStr.split("-")[2].split("T")[0]),int.parse(dateJoinedStr.split("-")[2].split("T")[1].split(":")[0]),int.parse(dateJoinedStr.split("-")[2].split("T")[1].split(":")[1]),int.parse(dateJoinedStr.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll("Z", "")));
    DateTime? lastLogin = (data["last_login"] == null )?null: DateTime.utc(int.parse(lastLoginDate.split("-")[0]),int.parse(lastLoginDate.split("-")[1]),int.parse(lastLoginDate.split("-")[2].split("T")[0]),int.parse(lastLoginDate.split("-")[2].split("T")[1].split(":")[0]),int.parse(lastLoginDate.split("-")[2].split("T")[1].split(":")[1]),int.parse(lastLoginDate.split("-")[2].split("T")[1].split(":")[2].split(".")[0].replaceAll("Z", "")));
    return User(
      id: data["id"],
      username: data["username"],
      email: data["email"],
      isActive: (data["is_active"] == null)? true: data["is_active"],
      isSuperuser: data["is_superuser"] ,
      isStaff: data["is_staff"],
      dateJoined: dateJoined,
      lastLogin:lastLogin,
    );
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
}
