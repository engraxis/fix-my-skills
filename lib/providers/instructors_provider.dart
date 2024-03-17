import 'package:fcg_admin_instructor/ui/auth/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/instructor.dart';
import '../res/keys.dart';
import '../res/static_info.dart';

class InstructorsProvider with ChangeNotifier {
  List<Instructor> _instructorsList = [];
  Map<String, dynamic> _availability;

  static bool instructorsLoading = true;

  Map<String, dynamic> get availability => _availability;
  List<Instructor> get instructorsList => _instructorsList;

  Future<void> createNewInstructor(Instructor instructor) async {
    await Firestore.instance
        .collection(Keys.instructors)
        .document(instructor.uid)
        .setData(instructor.toMap());
    _instructorsList.add(instructor);
    notifyListeners();
  }

  Future<void> updateInstructorStats(
    Instructor instructor,
    bool increase, {
    bool updateActiveAssignments = false,
    bool updateCompleted = false,
    bool updateReassignments = false,
    bool updateRejected = false,
  }) async {
    if (updateActiveAssignments)
      await Firestore.instance
          .collection(Keys.instructors)
          .document(instructor.uid)
          .setData({
        'totalActiveAssignments': increase
            ? instructor.totalActiveAssignments + 1
            : instructor.totalActiveAssignments - 1
      }, merge: true);
    if (updateCompleted)
      await Firestore.instance
          .collection(Keys.instructors)
          .document(instructor.uid)
          .setData({
        'totalCompleted': increase
            ? instructor.totalCompleted + 1
            : instructor.totalCompleted - 1
      }, merge: true);
    if (updateReassignments)
      await Firestore.instance
          .collection(Keys.instructors)
          .document(instructor.uid)
          .setData({
        'totalReassignments': increase
            ? instructor.totalReassignments + 1
            : instructor.totalReassignments - 1
      }, merge: true);
    if (updateRejected)
      await Firestore.instance
          .collection(Keys.instructors)
          .document(instructor.uid)
          .setData({
        'totalRejectedByAdmin': increase
            ? instructor.totalRejected + 1
            : instructor.totalRejected - 1
      }, merge: true);
  }

  Future<void> editInstructor(Instructor instructor) async {
    await Firestore.instance
        .collection(Keys.instructors)
        .document(instructor.uid)
        .setData(instructor.toMap());
    _instructorsList.removeAt(_instructorsList
        .indexWhere((element) => element.uid == instructor.uid));
    _instructorsList.add(instructor);
    notifyListeners();
  }

  Future<void> deleteInstructor(Instructor instructor) async {
    await Firestore.instance
        .collection(Keys.instructors)
        .document(instructor.uid)
        .delete();
    _instructorsList.removeWhere((element) => element.uid == instructor.uid);
    //Remove corresponding appointments
    //Remove corresponding chats
    //Put all the waiting videos in admin waiting section
    notifyListeners();
  }

  Future<void> updateProfile(Instructor instructor) async {
    await Firestore.instance
        .collection(Keys.instructors)
        .document(instructor.uid)
        .setData({
      'name': instructor.name,
      'pictureUrl': instructor.pictureUrl,
      'information': instructor.information,
      'price': instructor.price,
    }, merge: true);

    StaticInfo.currentUser = instructor;
    notifyListeners();
  }

  Future<void> fetchInstructorsList({bool showAll = false}) async {
    var documents =
        await Firestore.instance.collection(Keys.instructors).getDocuments();
    _instructorsList.clear();
    for (var docs in documents.documents) {
      if (showAll)
        _instructorsList.add(Instructor.fromMap(docs.data));
      else {
        if (docs.data['access'])
          _instructorsList.add(Instructor.fromMap(docs.data));
      }
    }
    notifyListeners();
  }

  Future<bool> fetchTimeTable(String uid, BuildContext context) async {
    try {
      var result = await Firestore.instance
          .collection(Keys.instructors)
          .document(uid)
          .collection(Keys.timeTable)
          .document(Keys.weeklyAvailability)
          .get();

      if (result.data == null) return false;

      _availability = result.data;
      notifyListeners();
      return true;
    } catch (e) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Login()), (_) => false);
      return false;
    }
  }

  Future<void> setInstructorOnlineStatus(bool status, String uid) async {
    await Firestore.instance
        .collection(Keys.instructors)
        .document(uid)
        .setData({'isOffline': status}, merge: true);
    notifyListeners();
  }

  Future<void> setInstructorAvailabilityFlag(String uid) async {
    await Firestore.instance
        .collection(Keys.instructors)
        .document(uid)
        .setData({'availability': true}, merge: true);
    notifyListeners();
  }

  Future<void> updateAvailability(
    String uid,
    List<Map<String, dynamic>> availability,
  ) async {
    await Firestore.instance
        .collection(Keys.instructors)
        .document(uid)
        .collection(Keys.timeTable)
        .document(Keys.weeklyAvailability)
        .setData({
      WeekDays.dayNames[0]: availability[availability.indexWhere(
              (element) => element.containsKey(WeekDays.dayNames[0]))]
          [WeekDays.dayNames[0]],
      WeekDays.dayNames[1]: availability[availability.indexWhere(
              (element) => element.containsKey(WeekDays.dayNames[1]))]
          [WeekDays.dayNames[1]],
      WeekDays.dayNames[2]: availability[availability.indexWhere(
              (element) => element.containsKey(WeekDays.dayNames[2]))]
          [WeekDays.dayNames[2]],
      WeekDays.dayNames[3]: availability[availability.indexWhere(
              (element) => element.containsKey(WeekDays.dayNames[3]))]
          [WeekDays.dayNames[3]],
      WeekDays.dayNames[4]: availability[availability.indexWhere(
              (element) => element.containsKey(WeekDays.dayNames[4]))]
          [WeekDays.dayNames[4]],
      WeekDays.dayNames[5]: availability[availability.indexWhere(
              (element) => element.containsKey(WeekDays.dayNames[5]))]
          [WeekDays.dayNames[5]],
      WeekDays.dayNames[6]: availability[availability.indexWhere(
              (element) => element.containsKey(WeekDays.dayNames[6]))]
          [WeekDays.dayNames[6]],
    });
    notifyListeners();
  }
}
