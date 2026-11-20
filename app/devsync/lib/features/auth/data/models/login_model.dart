class LoginModel {
  final String email;
  final String password;
  LoginModel({required this.password,required this.email});

  factory LoginModel.fromJson(Map<String,String> json){
    return LoginModel(password: json["password"]??"", email: json["email"]??"");

  }
Map<String, String> toJson() {
  return {
    'password': password,
    'email': email,
  };
}
}