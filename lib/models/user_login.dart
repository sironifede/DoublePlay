class UserLogin {
  String username;
  String password;

  UserLogin({required this.username, required this.password});

  Map <String, dynamic> toJson() => {
    "username": this.username,
    "password": this.password
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
      "token": this.token,
    };
  }
}

