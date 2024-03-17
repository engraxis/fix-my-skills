import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../res/static_info.dart';
import '../res/keys.dart';
import '../models/appointment.dart';

class AppointmentsProvider with ChangeNotifier {
  List<Appointment> _appointments = [];

  List<Appointment> get appointments {
    List<Appointment> _ret = [];
    _ret.addAll(_appointments.reversed);
    return _ret;
  }

  Future<void> cancelAppointment(Appointment appointment) async {
    // 1. Delete appointment from instructor
    // 2. Delete appointment from user
    await Firestore.instance // 1
        .collection(Keys.appointments)
        .document(appointment.uid)
        .delete();
    _appointments.removeAt(
        _appointments.indexWhere((element) => element.uid == appointment.uid));
    notifyListeners();
  }

  Future<void> fetchAppointments() async {
    var appointmentSnapshot = await Firestore.instance
        .collection(Keys.appointments)
        .where('instructorUid', isEqualTo: StaticInfo.currentUser.uid)
        .getDocuments();
    var appointmentsDocs = appointmentSnapshot.documents;
    _appointments.clear();
    for (var i in appointmentsDocs)
      _appointments.add(Appointment.fromMap(i.data));
    notifyListeners();
  }

  Future<void> deleteAllAppointments(String instructorId) async {
    var appointmentsDocs = (await Firestore.instance
            .collection(Keys.appointments)
            .where('instructorUid', isEqualTo: instructorId)
            .getDocuments())
        .documents;
    _appointments.clear();

    for (var i in appointmentsDocs)
      _appointments.add(Appointment.fromMap(i.data));

    _appointments.forEach((element) async => await cancelAppointment(element));

    _appointments.clear();
    notifyListeners();
  }
}
