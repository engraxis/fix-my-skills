import 'package:flutter/foundation.dart';

class Appointment {
  String uid;
  String appointmentDayTime;
  String userUid;
  String instructorUid;
  String mergeUids;
  String userName;
  String userPicUrl;

  Appointment({
    @required this.uid,
    @required this.appointmentDayTime,
    @required this.userUid,
    @required this.instructorUid,
    @required this.mergeUids,
    @required this.userName,
    @required this.userPicUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'appointmentDayTime': this.appointmentDayTime,
      'userUid': this.userUid,
      'instructorUid': this.instructorUid,
      'mergeUids': this.mergeUids,
      'userName': this.userName,
      'userPicUrl': this.userPicUrl,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return new Appointment(
      uid: map['uid'] as String,
      appointmentDayTime: map['appointmentDayTime'] as String,
      userUid: map['userUid'] as String,
      instructorUid: map['instructorUid'] as String,
      mergeUids: map['mergeUids'] as String,
      userName: map['userName'] as String,
      userPicUrl: map['userPicUrl'] as String,
    );
  }
}
