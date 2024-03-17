import 'package:flutter/foundation.dart';

class User {
  String uid, name, email, pictureUrl;
  bool isFbLogin;

  User({
    @required this.uid,
    @required this.name,
    @required this.email,
    @required this.pictureUrl,
    @required this.isFbLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email': this.email,
      'pictureUrl': this.pictureUrl,
      'isFbLogin': this.isFbLogin,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return new User(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      pictureUrl: map['pictureUrl'] as String,
      isFbLogin: map['isFbLogin'] as bool,
    );
  }
}
