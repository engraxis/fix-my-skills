import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/instructor.dart';
import '../res/keys.dart';
import '../res/static_info.dart';

class AuthHelper {
  static const ADMIN_NAME = 'Admin';
  static const ADMIN_EMAIL = 'info@flycheergear.com';
  static const ADMIN_PASSWORD = '#adMIN123';
  static const ADMIN_PIC_URL = 'https://firebasestorage.googleapis.com/v0/b/fix-my-skills-2.appspot.com/o/print-173513015.jpg?alt=media&token=5e320d50-4bc6-43f4-820b-ffdb7bbcb988';
  static const ADMIN_UID = 'JgZ8vMUB2Bd2qLan3p6550cEnl73';

  Future<String> signUp(Instructor user, String password) async {
    try {
      var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      if (result.user == null) return '';
      user.uid = result.user.uid;
      await Firestore.instance
          .collection(Keys.users)
          .document(user.uid)
          .setData(user.toMap());
      StaticInfo.currentUser = user;
      await OneSignal.shared.sendTag(StaticInfo.currentUser.uid, "yes");
      return null;
    } catch (e) {
      print('Error in signing up $e');
      return e.code;
    }
  }

  Future<String> signUpByAdmin({String email, String password}) async {
    try {
      var result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == null) return '';
      StaticInfo.LastSignedUpInstructor = result.user.uid;
      //await OneSignal.shared.sendTag(result.user.uid, "yes");
      var newResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: ADMIN_EMAIL, password: ADMIN_PASSWORD);
      //await OneSignal.shared.sendTag(newResult.user.uid, "yes");
      return null;
    } catch (e) {
      print('Error in signing up $e');
      return e.code;
    }
  }

  Future<String> login(String email, String password) async {
    try {
      var result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) return '';
      if (result.user.email == null) return null;

      if (email.toLowerCase() == ADMIN_EMAIL){
        print('okkkkkkkkkkkkkkkkkkk 01');
        StaticInfo.currentUser = new Instructor(
          uid: ADMIN_UID,
          name: ADMIN_NAME,
          email: ADMIN_EMAIL,
          isInstructor: false,
          pictureUrl: ADMIN_PIC_URL,
          information: null,
          price: null,
        );
      }

      if (email != ADMIN_EMAIL) {
        var userData = (await Firestore.instance
                .collection(Keys.instructors)
                .document(result.user.uid)
                .get())
            .data;
        if (userData == null) return 'Can not log in.';
        StaticInfo.currentUser = Instructor.fromMap(userData);
      }
      
      await OneSignal.shared.sendTag(StaticInfo.currentUser.uid, "yes");
      return null;
    } catch (e) {
      print('error in login $e');
      return 'Error: $e';
    }
  }

  Future<Instructor> getCurrentUser() async {
    try {
      var result = await FirebaseAuth.instance.currentUser();
      if (result == null) return null;
      
      if (result.email == null) return null;
      if (result.email == ADMIN_EMAIL) {
        Instructor admin = Instructor(
          uid: ADMIN_UID,
          name: ADMIN_NAME,
          email: ADMIN_EMAIL,
          access: null,
          isInstructor: false,
          pictureUrl: ADMIN_PIC_URL,
          information: null,
          price: null,
        );
        StaticInfo.currentUser = admin;
        return admin;
      } else {
        var data = (await Firestore.instance
                .collection(Keys.instructors)
                .document(result.uid)
                .get())
            .data;
        if (data == null) return null;
        Instructor user = Instructor.fromMap(data);
        StaticInfo.currentUser = user;
        return user;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error in password reset $e');
      return false;
    }
  }
}
