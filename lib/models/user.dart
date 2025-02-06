import 'package:chessudoku/enums/login_type.dart';

class User {
  final String uid;
  final String? email;
  final LoginType loginType;

  User({required this.uid, this.email, required this.loginType});

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'loginType': loginType.toJson()};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(uid: map['uid'], email: map['email'], loginType: LoginType.fromJson(map['loginType']));
  }
}
