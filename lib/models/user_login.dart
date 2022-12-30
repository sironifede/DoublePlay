class UserLogin {
  String username;
  String password;

  UserLogin({required this.username, required this.password});

  Map <String, dynamic> toJson() => {
    "username": username,
    "password": password
  };
}

class UserPassword {
  int id;
  String password;
  String password2;

  UserPassword({required this.id, required this.password, required this.password2});

  Map <String, dynamic> toJson() => {
    "password": password,
    "password2": password2
  };
}

class Token{
  String token;

  Token({required this.token});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
    };
  }
}

