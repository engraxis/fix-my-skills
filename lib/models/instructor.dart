import 'package:flutter/foundation.dart';

class Instructor {
  String uid, name, email, pictureUrl, information;
  bool isInstructor, access, isOffline, availability;
  int totalRejected, totalActiveAssignments, totalReassignments, totalCompleted;
  double price;

  Instructor({
    @required this.uid,
    @required this.name,
    @required this.email,
    @required this.isInstructor,
    @required this.pictureUrl,
    this.access = true,
    this.availability = false,
    this.isOffline = false,
    this.totalRejected = 0,
    this.totalActiveAssignments = 0,
    this.totalReassignments = 0,
    this.totalCompleted = 0,
    @required this.price,
    @required this.information,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email': this.email,
      'isInstructor': this.isInstructor,
      'pictureUrl': this.pictureUrl,
      'access': this.access,
      'availability': this.availability,
      'isOffline': this.isOffline,
      'totalRejected': this.totalRejected,
      'totalActiveAssignments': this.totalActiveAssignments,
      'totalReassignments': this.totalReassignments,
      'totalCompleted': this.totalCompleted,
      'price': this.price,
      'information': this.information,
    };
  }

  factory Instructor.fromMap(Map<String, dynamic> map) {
    return new Instructor(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      isInstructor: map['isInstructor'] as bool,
      pictureUrl: map['pictureUrl'] as String,
      access: map['access'] as bool,
      availability: map['availability'] as bool,
      isOffline: map['isOffline'] as bool,
      totalRejected: map['totalRejected'] as int,
      totalActiveAssignments: map['totalActiveAssignments'] as int,
      totalReassignments: map['totalReassignments'] as int,
      totalCompleted: map['totalCompleted'] as int,
      information: map['information'] as String,
      price: map['price'].toDouble() as double,
    );
  }
}
