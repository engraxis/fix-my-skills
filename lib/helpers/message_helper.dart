import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcg_admin_instructor/helpers/auth_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../res/keys.dart';
import '../res/static_info.dart';

class MessageHelper {
  static List<String> deletedInstructorsUids = [];

  StreamSubscription _msgSubscription;
  StreamController<List<Message>> _msgStreamController;
  Sink<List<Message>> _msgSink;
  Stream<List<Message>> _messageStream;
  Stream<List<Message>> get messageStream => _messageStream;

  MessageHelper.withMsgStreamInitialized(String uid) {
    _msgStreamController = StreamController<List<Message>>();
    _msgSink = _msgStreamController.sink;
    _messageStream = _msgStreamController.stream;

    _readMsgData(uid);
  }

  StreamSubscription _chatSubscription;
  StreamController<List<Chat>> _chatStreamController;
  Sink<List<Chat>> _chatSink;
  Stream<List<Chat>> _chatStream;
  Stream<List<Chat>> get chatStream => _chatStream;

  MessageHelper.withChatStreamInitialized({@required bool isAdmin}) {
    _chatStreamController = StreamController<List<Chat>>();
    _chatSink = _chatStreamController.sink;
    _chatStream = _chatStreamController.stream;

    isAdmin ? _readChatDataAdmin() : _readChatDataInstructor();
  }

  _readMsgData(String uid) {
    _msgSubscription = Firestore.instance
        .collection(Keys.messages)
        .where('usersUidsMerge', whereIn: [
          '$uid${StaticInfo.currentUser.uid}',
          '${StaticInfo.currentUser.uid}$uid'
        ])
        .orderBy('msgId')
        .snapshots()
        .listen((event) {
          List<Message> data = [];
          for (var doc in event.documents) data.add(Message.fromMap(doc.data));
          _msgSink.add(data);
        });
  }

   static Future<void> deleteUserChat(String instructorId) async {
    var msgList1 = (await Firestore.instance
            .collection(Keys.messages)
            .where('senderUid', isEqualTo: instructorId)
            .getDocuments())
        .documents;
    msgList1.forEach((element) async {
      await Firestore.instance
          .collection(Keys.messages)
          .document(element.documentID)
          .delete();
    });

    var msgList2 = (await Firestore.instance
            .collection(Keys.messages)
            .where('receiverUid', isEqualTo: instructorId)
            .getDocuments())
        .documents;
    msgList2.forEach((element) async {
      await Firestore.instance
          .collection(Keys.messages)
          .document(element.documentID)
          .delete();
    });

    var chatList = (await Firestore.instance
            .collection(Keys.instructors)
            .document(instructorId)
            .collection(Keys.myChats)
            .getDocuments())
        .documents;

    chatList.forEach((element) async {
      await Firestore.instance
          .collection(Keys.users)
          .document(element.documentID)
          .collection(Keys.myChats)
          .document(instructorId).delete();
    });
  }

  _readChatDataAdmin() {
    _chatSubscription = Firestore.instance
        .collection(Keys.admin)
        .document(StaticInfo.currentUser.uid)
        .collection(Keys.myChats)
        .snapshots()
        .listen((event) async {
      List<Chat> data = [];
      Timestamp timeStamp;
      bool newMsg = false;
      for (var doc in event.documents) {
        timeStamp = doc.data['key'];
        newMsg = doc.data['newMsg'];
        String uid;
        String name;
        var userData = (await Firestore.instance
                .collection(Keys.instructors)
                .document(doc.documentID)
                .get())
            .data;
        if (userData == null) continue;
        User user = User.fromMap(userData);
        uid = user.uid;
        name = user.name;
        data.add(Chat(uid, name, timeStamp, newMsg));
      }
      _chatSink.add(data);
    });
  }

  _readChatDataInstructor() {
    _chatSubscription = Firestore.instance
        .collection(Keys.instructors)
        .document(StaticInfo.currentUser.uid)
        .collection(Keys.myChats)
        .snapshots()
        .listen((event) async {
      List<Chat> data = [];
      Timestamp timeStamp;
      bool newMsg = false;
      for (var doc in event.documents) {
        timeStamp = doc.data['key'];
        newMsg = doc.data['newMsg'];
        String uid;
        String name;
        var userData = (await Firestore.instance
                .collection(Keys.users)
                .document(doc.documentID)
                .get())
            .data;
        if (userData == null) {
          uid = AuthHelper.ADMIN_UID;
          name = AuthHelper.ADMIN_NAME;
        } else {
          User user = User.fromMap(userData);
          uid = user.uid;
          name = user.name;
        }
        data.add(Chat(uid, name, timeStamp, newMsg));
      }
      _chatSink.add(data);
    });
  }

  void dispose() {
    _msgSubscription?.cancel();
    _msgStreamController?.close();
    _chatSubscription?.cancel();
    _chatStreamController?.close();
  }

  Future<void> sentMessage(Message msg, DateTime time) async {
    try {
      if (msg.url != null) {
        var r = await (await FirebaseStorage.instance
                .ref()
                .child('message')
                .child(DateTime.now().millisecondsSinceEpoch.toString())
                .putFile(File(msg.url))
                .onComplete)
            .ref
            .getDownloadURL();
        msg.url = r;
      }

      await Firestore.instance
          .collection(Keys.messages)
          .document(msg.msgId)
          .setData(msg.toMap());

      StaticInfo.currentUser.email == AuthHelper.ADMIN_EMAIL
          ? await Firestore.instance
              .collection(Keys.admin)
              .document(msg.senderUid)
              .collection(Keys.myChats)
              .document(msg.receiverUid)
              .setData({'key': time})
          : await Firestore.instance
              .collection(Keys.instructors)
              .document(msg.senderUid)
              .collection(Keys.myChats)
              .document(msg.receiverUid)
              .setData({'key': time});

      StaticInfo.currentUser.email == AuthHelper.ADMIN_EMAIL
          ? await Firestore.instance
              .collection(Keys.instructors)
              .document(msg.receiverUid)
              .collection(Keys.myChats)
              .document(msg.senderUid)
              .setData({'key': time, 'newMsg': true})
          : msg.receiverUid == AuthHelper.ADMIN_UID
              ? await Firestore.instance
                  .collection(Keys.admin)
                  .document(msg.receiverUid)
                  .collection(Keys.myChats)
                  .document(msg.senderUid)
                  .setData({'key': time, 'newMsg': true})
              : await Firestore.instance
                  .collection(Keys.users)
                  .document(msg.receiverUid)
                  .collection(Keys.myChats)
                  .document(msg.senderUid)
                  .setData({'key': time, 'newMsg': true});
    } catch (e) {
      print(e.toString());
    }
  }
}
