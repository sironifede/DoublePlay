class UserSignUp {
  String? username, email, password, password2;
  bool? isStaff  = false;
  bool? isSuperuser = false;

  UserSignUp({this.username, this.email, this.password, this.password2, this.isStaff, this.isSuperuser});

  Map <String, dynamic> toJson() => {
    "username": username,
    "password": password,
    "password2": password2,
    "is_staff": isStaff,
    "is_superuser": isSuperuser,
  };
}