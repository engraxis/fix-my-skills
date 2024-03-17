import 'package:fcg_admin_instructor/models/instructor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/video.dart';
import '../res/keys.dart';
import '../res/static_info.dart';

class VideosProvider with ChangeNotifier {
  // Common for both Instructor and Admin

  Future<List<String>> getLinks() async {
    DocumentSnapshot links = await Firestore.instance
        .collection(Keys.config)
        .document(Keys.links)
        .get();
    var faqLink = links.data['faqLink'];
    var privacyLink = links.data['privacyLink'];
    var termsLink = links.data['termsLink'];
    return [faqLink, privacyLink, termsLink];
  }

  Future<void> updateVideo(Video video) async {
    await Firestore.instance // 2
        .collection(Keys.videos)
        .document(video.videoId)
        .setData(video.toMap());
  }

  Future<String> uploadVideo(
      File videoFile, String userId, String upDatedVideoId) async {
    //String upDatedVideoId = DateTime.now().millisecondsSinceEpoch.toString();

    var uploadVideoTask = FirebaseStorage.instance
        .ref()
        .child(userId)
        .child(Keys.videos)
        .child(upDatedVideoId)
        .putFile(videoFile);

    var videoUrl =
        await (await uploadVideoTask.onComplete).ref.getDownloadURL();

    return videoUrl;
  }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  //                             Instructor Side
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  List<Video> _instructorWaitingVideos = [];
  List<Video> _instructorCompletedVideos = [];
  static bool instructorWaitingVideosLoading = true;
  static bool instructorCompletedVideosLoading = true;

  List<Video> get instructorsWaitingVideos => _instructorWaitingVideos;
  List<Video> get instructorsCompletedVideos => _instructorCompletedVideos;

  Future<void> sendToAdmin(Video video) async {
    // 1. Remove adminAssigned
    // 2. Add adminUpdated
    // 3. Remove instructorWaiting

    await Firestore.instance // 1
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminAssigned)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 2
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminUpdated)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    await Firestore.instance // 3
        .collection(Keys.instructors)
        .document(video.instructorId)
        .collection(Keys.instructorWaiting)
        .document(video.videoId)
        .delete();

    _instructorWaitingVideos
        .removeWhere((element) => element.videoId == video.videoId);
    notifyListeners();
  }

  Future<void> subscribeInstructorWaitingVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];

    Firestore.instance
        .collection(Keys.instructors)
        .document(StaticInfo.currentUser.uid)
        .collection(Keys.instructorWaiting)
        .snapshots()
        .listen((event) async {
      bufferVideos.clear();
      documentIds.clear();
      event.documents.forEach((element) {
        documentIds.add(element.documentID);
      });

      if (documentIds.isEmpty) {
        _instructorWaitingVideos.clear();
        notifyListeners();
        return;
      }

      List<List<String>> chunkedList = [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        []
      ];
      int index = 0;
      int lastIndex = 0;
      int loopIteration = (documentIds.length / 10).toInt();
      for (int i = 0; i < loopIteration; i++) {
        chunkedList
            .elementAt(i)
            .addAll(documentIds.sublist(index, index + 9 + 1));
        index += 10;
        lastIndex = i;
      }

      chunkedList
          .elementAt(lastIndex + 1)
          .addAll(documentIds.sublist(index, documentIds.length));

      for (int i = 0; i < lastIndex + 1; i++) {
        if (chunkedList.elementAt(i).isNotEmpty) {
          var completedVideos1 = await Firestore.instance
              .collection(Keys.videos)
              .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
              .getDocuments();
          var videoDocs = completedVideos1.documents;
          for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
        }
      }
      if (chunkedList.elementAt(lastIndex + 1).length != 0) {
        var completedVideos2 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
            .getDocuments();
        var videoDocs = completedVideos2.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
      _instructorWaitingVideos.clear();
      _instructorWaitingVideos.addAll(bufferVideos);
      notifyListeners();
    });
  }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  //                             Admin Side
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////
  List<Video> _adminWaitingVideos = [];
  List<Video> _adminAssignedVideos = [];
  List<Video> _adminUpdatedVideos = [];
  List<Video> _adminFinalisedVideos = [];
  List<Video> _adminFeaturedVideos = [];
  static bool adminWaitingVideosLoading = true;
  static bool adminAssignedVideosLoading = true;
  static bool adminUpdatedVideosLoading = true;
  static bool adminFinalisedVideosLoading = true;

  List<Video> get adminWaitingVideos => _adminWaitingVideos;
  List<Video> get adminAssignedVideos => _adminAssignedVideos;
  List<Video> get adminUpdatedVideos => _adminUpdatedVideos;
  List<Video> get adminFinalisedVideos => _adminFinalisedVideos;
  List<Video> get adminFeaturedVideos => _adminFeaturedVideos;

  Future<void> instructorWaitingVideosReturn(Instructor instructor) async {
    // 1 : Remove admin assigned
    // 2 : Add admin waiting from waiting and change videos status
    // 3 : Add admin waiting from updated and changed videos status

    // Instructors videos will be automatically deleted

    List<DocumentSnapshot> refactorVideos = (await Firestore.instance
            .collection(Keys.instructors)
            .document(instructor.uid)
            .collection(Keys.instructorWaiting)
            .getDocuments())
        .documents;

    refactorVideos.forEach((element) async {
      await Firestore.instance
          .collection(Keys.admin)
          .document(Keys.videos)
          .collection(Keys.adminAssigned)
          .document(element.data['videoId'])
          .delete();
    });

    refactorVideos.forEach((element) async {
      await Firestore.instance
          .collection(Keys.admin)
          .document(Keys.videos)
          .collection(Keys.adminWaiting)
          .document(element.data['videoId'])
          .setData({Keys.videoId: element.data['videoId']});

      await Firestore.instance
          .collection(Keys.videos)
          .document(element.data['videoId'])
          .setData({
        'status': 'waiting',
        'instructorId': '',
        'isRejected': false,
        'isUploadedURL': false,
      }, merge: true);
    });

    refactorVideos.forEach((refactorVideo) {
      _adminWaitingVideos.add(_adminAssignedVideos.firstWhere((assignedVideo) =>
          assignedVideo.videoId == refactorVideo.documentID));

      _adminAssignedVideos.removeWhere(
          (assignedVideo) => refactorVideo.documentID == assignedVideo.videoId);
    });

    _adminWaitingVideos.forEach((element) {
      element.status = 'waiting';
      element.instructorId = '';
      element.isRejected = false;
      element.isUploadedURL = false;
    });

    List<Video> removeAdminUpdated = [];
    removeAdminUpdated.addAll(adminUpdatedVideos
        .where((element) => element.instructorId == instructor.uid));

    removeAdminUpdated.forEach((element1) async {
      element1.status = 'waiting';
      element1.instructorId = '';
      element1.isRejected = false;
      element1.isUploadedURL = false;
      _adminAssignedVideos
          .removeWhere((element2) => element1.videoId == element2.videoId);
      _adminWaitingVideos.add(element1);

      await Firestore.instance
          .collection(Keys.admin)
          .document(Keys.videos)
          .collection(Keys.adminWaiting)
          .document(element1.videoId)
          .setData({Keys.videoId: element1.videoId});

      await Firestore.instance
          .collection(Keys.videos)
          .document(element1.videoId)
          .setData({
        'status': 'waiting',
        'instructorId': '',
        'isRejected': false,
        'isUploadedURL': false,
      }, merge: true);
    });

    notifyListeners();
  }

  Future<void> earlyAcceptAndDeliver(Video video) async {
    // 1. Remove adminWaiting
    // 2. Add adminFinalised
    // 3. Remove userWaiting
    // 4. Add userCompleted

    await Firestore.instance // 1
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminWaiting)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 2
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminFinalised)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    await Firestore.instance // 3
        .collection(Keys.users)
        .document(video.userId)
        .collection(Keys.userWaiting)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 4
        .collection(Keys.users)
        .document(video.userId)
        .collection(Keys.userCompleted)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    //Admin side updating only
    _adminWaitingVideos
        .removeWhere((element) => element.videoId == video.videoId);
    _adminFinalisedVideos.add(video);
    notifyListeners();
  }

  Future<void> acceptAndDeliver(Video video) async {
    // 1. Remove adminUpated
    // 2. Add adminFinalised
    // 3. Remove InstructorWaiting
    // 4. Add instructorCompleted
    // 5. Remove userWaiting
    // 6. Add userCompleted

    await Firestore.instance // 1
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminUpdated)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 2
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminFinalised)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    await Firestore.instance // 3
        .collection(Keys.instructors)
        .document(video.instructorId)
        .collection(Keys.instructorWaiting)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 4
        .collection(Keys.instructors)
        .document(video.instructorId)
        .collection(Keys.instructorCompleted)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    await Firestore.instance // 5
        .collection(Keys.users)
        .document(video.userId)
        .collection(Keys.userWaiting)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 6
        .collection(Keys.users)
        .document(video.userId)
        .collection(Keys.userCompleted)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    //Admin side updating only
    _adminUpdatedVideos
        .removeWhere((element) => element.videoId == video.videoId);
    _adminFinalisedVideos.add(video);
    notifyListeners();
  }

  Future<void> addFeatured(Video video) async {
    await Firestore.instance
        .collection(Keys.adminFeatured)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});
    _adminFeaturedVideos.add(video);
  }

  Future<void> removeFeatured(Video video) async {
    await Firestore.instance
        .collection(Keys.adminFeatured)
        .document(video.videoId)
        .delete();
    _adminFeaturedVideos.remove(video);
  }

  Future<void> fetchWaitingVideosdel() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];
    var _waitingVideos = [];
    var videoList = await Firestore.instance
        .collection(Keys.users)
        .document(StaticInfo.currentUser.uid)
        .collection(Keys.userWaiting)
        .getDocuments();

    if (videoList.documents.isEmpty) {
      _waitingVideos.clear();
      notifyListeners();
      return;
    }

    for (var doc in videoList.documents) documentIds.add(doc.documentID);

    List<List<String>> chunkedList = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ];
    int index = 0;
    int lastIndex = 0;
    int loopIteration = (documentIds.length / 10).toInt();
    for (int i = 0; i < loopIteration; i++) {
      chunkedList
          .elementAt(i)
          .addAll(documentIds.sublist(index, index + 9 + 1));
      index += 10;
      lastIndex = i;
    }

    chunkedList
        .elementAt(lastIndex + 1)
        .addAll(documentIds.sublist(index, documentIds.length));

    for (int i = 0; i < lastIndex + 1; i++) {
      if (chunkedList.elementAt(i).isNotEmpty) {
        var waitingVideos1 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
            .getDocuments();
        var videoDocs = waitingVideos1.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
    }
    var waitingVideos2 = await Firestore.instance
        .collection(Keys.videos)
        .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
        .getDocuments();
    var videoDocs = waitingVideos2.documents;
    for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
    _waitingVideos.clear();
    _waitingVideos.addAll(bufferVideos);
    notifyListeners();
  }

  Future<void> fetchInstructorWaitingVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];

    var videoList = await Firestore.instance
        .collection(Keys.instructors)
        .document(StaticInfo.currentUser.uid)
        .collection(Keys.instructorWaiting)
        .getDocuments();

    if (videoList.documents.isEmpty) {
      _instructorWaitingVideos.clear();
      notifyListeners();
      return;
    }

    for (var doc in videoList.documents) documentIds.add(doc.documentID);

    List<List<String>> chunkedList = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ];
    int index = 0;
    int lastIndex = 0;
    int loopIteration = (documentIds.length / 10).toInt();
    for (int i = 0; i < loopIteration; i++) {
      chunkedList
          .elementAt(i)
          .addAll(documentIds.sublist(index, index + 9 + 1));
      index += 10;
      lastIndex = i;
    }

    chunkedList
        .elementAt(lastIndex + 1)
        .addAll(documentIds.sublist(index, documentIds.length));

    for (int i = 0; i < lastIndex + 1; i++) {
      if (chunkedList.elementAt(i).isNotEmpty) {
        var waitingVideos1 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
            .getDocuments();
        var videoDocs = waitingVideos1.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
    }
    if (chunkedList.elementAt(lastIndex + 1).length != 0) {
      var waitingVideos2 = await Firestore.instance
          .collection(Keys.videos)
          .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
          .getDocuments();
      var videoDocs = waitingVideos2.documents;
      for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
    }

    _instructorWaitingVideos.clear();
    _instructorWaitingVideos.addAll(bufferVideos);
    notifyListeners();
  }

  Future<void> subscribeInstructorCompletedVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];

    Firestore.instance
        .collection(Keys.instructors)
        .document(StaticInfo.currentUser.uid)
        .collection(Keys.instructorCompleted)
        .snapshots()
        .listen((event) async {
      bufferVideos.clear();
      documentIds.clear();
      event.documents.forEach((element) {
        documentIds.add(element.documentID);
      });

      if (documentIds.isEmpty) {
        _instructorCompletedVideos.clear();
        notifyListeners();
        return;
      }

      List<List<String>> chunkedList = [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        []
      ];
      int index = 0;
      int lastIndex = 0;
      int loopIteration = (documentIds.length / 10).toInt();
      for (int i = 0; i < loopIteration; i++) {
        chunkedList
            .elementAt(i)
            .addAll(documentIds.sublist(index, index + 9 + 1));
        index += 10;
        lastIndex = i;
      }

      chunkedList
          .elementAt(lastIndex + 1)
          .addAll(documentIds.sublist(index, documentIds.length));

      for (int i = 0; i < lastIndex + 1; i++) {
        if (chunkedList.elementAt(i).isNotEmpty) {
          var waitingVideos1 = await Firestore.instance
              .collection(Keys.videos)
              .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
              .getDocuments();
          var videoDocs = waitingVideos1.documents;
          for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
        }
      }
      if (chunkedList.elementAt(lastIndex + 1).length != 0) {
        var waitingVideos2 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
            .getDocuments();
        var videoDocs = waitingVideos2.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }

      _instructorCompletedVideos.clear();
      _instructorCompletedVideos.addAll(bufferVideos);
      notifyListeners();
    });
  }

  Future<void> decline(Video video) async {
    // 1. Remove adminUpdated
    // 2. Add adminAssigned
    // 3. Add instructorWaiting

    await Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminUpdated)
        .document(video.videoId)
        .delete();

    await Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminAssigned)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    await Firestore.instance
        .collection(Keys.instructors)
        .document(video.instructorId)
        .collection(Keys.instructorWaiting)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    _adminUpdatedVideos
        .removeWhere((element) => element.videoId == video.videoId);
    /*_adminAssignedVideos.add(video);*/
    notifyListeners();
  }

  Future<void> fetchInstructorCompletedVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];

    var videoList = await Firestore.instance
        .collection(Keys.instructors)
        .document(StaticInfo.currentUser.uid)
        .collection(Keys.instructorCompleted)
        .getDocuments();

    if (videoList.documents.isEmpty) {
      _instructorCompletedVideos.clear();
      notifyListeners();
      return;
    }

    for (var doc in videoList.documents) documentIds.add(doc.documentID);

    List<List<String>> chunkedList = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ];
    int index = 0;
    int lastIndex = 0;
    int loopIteration = (documentIds.length / 10).toInt();
    for (int i = 0; i < loopIteration; i++) {
      chunkedList
          .elementAt(i)
          .addAll(documentIds.sublist(index, index + 9 + 1));
      index += 10;
      lastIndex = i;
    }

    chunkedList
        .elementAt(lastIndex + 1)
        .addAll(documentIds.sublist(index, documentIds.length));

    for (int i = 0; i < lastIndex + 1; i++) {
      if (chunkedList.elementAt(i).isNotEmpty) {
        var waitingVideos1 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
            .getDocuments();
        var videoDocs = waitingVideos1.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
    }
    if (chunkedList.elementAt(lastIndex + 1).length != 0) {
      var waitingVideos2 = await Firestore.instance
          .collection(Keys.videos)
          .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
          .getDocuments();
      var videoDocs = waitingVideos2.documents;
      for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
    }
    _instructorCompletedVideos.clear();
    _instructorCompletedVideos.addAll(bufferVideos);
    notifyListeners();
  }

  Future<void> fetchAdminWaitingVideos() async {
    List<String> documentIds = [];
    List<Video> bufferVideos = [];

    var videoList = await Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminWaiting)
        .getDocuments();

    if (videoList.documents.isEmpty) {
      _adminWaitingVideos.clear();
      notifyListeners();
      return;
    }

    for (var doc in videoList.documents) documentIds.add(doc.documentID);
    List<List<String>> chunkedList = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ];
    int index = 0;
    int lastIndex = 0;
    int loopIteration = (documentIds.length / 10).toInt();
    for (int i = 0; i < loopIteration; i++) {
      chunkedList
          .elementAt(i)
          .addAll(documentIds.sublist(index, index + 9 + 1));
      index += 10;
      lastIndex = i;
    }

    chunkedList
        .elementAt(lastIndex + 1)
        .addAll(documentIds.sublist(index, documentIds.length));

    for (int i = 0; i < lastIndex + 1; i++) {
      if (chunkedList.elementAt(i).isNotEmpty) {
        var waitingVideos1 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
            .getDocuments();
        var videoDocs = waitingVideos1.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
    }
    print('................ OK ........................');
    if (chunkedList.elementAt(lastIndex + 1).length != 0) {
      print(chunkedList.elementAt(lastIndex + 1).length);
      print(chunkedList.length);
      var waitingVideos2 = await Firestore.instance
          .collection(Keys.videos)
          .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
          .getDocuments();
      print('...................... NOK .............................');
      var videoDocs = waitingVideos2.documents;

      for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
    }
    _adminWaitingVideos.clear();
    _adminWaitingVideos.addAll(bufferVideos);
    notifyListeners();
  }

  Future<void> fetchAdminAssignedVideos() async {
    List<String> documentIds = [];
    List<Video> bufferVideos = [];

    var videoList = await Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminAssigned)
        .getDocuments();

    if (videoList.documents.isEmpty) {
      _adminAssignedVideos.clear();
      notifyListeners();
      return;
    }

    for (var doc in videoList.documents) documentIds.add(doc.documentID);

    List<List<String>> chunkedList = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ];
    int index = 0;
    int lastIndex = 0;
    int loopIteration = (documentIds.length / 10).toInt();
    for (int i = 0; i < loopIteration; i++) {
      chunkedList
          .elementAt(i)
          .addAll(documentIds.sublist(index, index + 9 + 1));
      index += 10;
      lastIndex = i;
    }

    chunkedList
        .elementAt(lastIndex + 1)
        .addAll(documentIds.sublist(index, documentIds.length));

    for (int i = 0; i < lastIndex + 1; i++) {
      if (chunkedList.elementAt(i).isNotEmpty) {
        var waitingVideos1 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
            .getDocuments();
        var videoDocs = waitingVideos1.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
    }
    if (chunkedList.elementAt(lastIndex + 1).length != 0) {
      var waitingVideos2 = await Firestore.instance
          .collection(Keys.videos)
          .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
          .getDocuments();
      var videoDocs = waitingVideos2.documents;
      for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
    }
    _adminAssignedVideos.clear();
    _adminAssignedVideos.addAll(bufferVideos);
    notifyListeners();
  }

  Future<void> fetchAdminUpdatedVideos() async {
    List<String> documentIds = [];
    List<Video> bufferVideos = [];
    var videoList = await Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminUpdated)
        .getDocuments();

    if (videoList.documents.isEmpty) {
      _adminUpdatedVideos.clear();
      notifyListeners();
      return;
    }

    for (var doc in videoList.documents) documentIds.add(doc.documentID);
    List<List<String>> chunkedList = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ];
    int index = 0;
    int lastIndex = 0;
    int loopIteration = (documentIds.length / 10).toInt();
    for (int i = 0; i < loopIteration; i++) {
      chunkedList
          .elementAt(i)
          .addAll(documentIds.sublist(index, index + 9 + 1));
      index += 10;
      lastIndex = i;
    }

    chunkedList
        .elementAt(lastIndex + 1)
        .addAll(documentIds.sublist(index, documentIds.length));

    for (int i = 0; i < lastIndex + 1; i++) {
      if (chunkedList.elementAt(i).isNotEmpty) {
        var waitingVideos1 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
            .getDocuments();
        var videoDocs = waitingVideos1.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
    }
    if (chunkedList.elementAt(lastIndex + 1).length != 0) {
      var waitingVideos2 = await Firestore.instance
          .collection(Keys.videos)
          .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
          .getDocuments();
      var videoDocs = waitingVideos2.documents;
      for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
    }
    _adminUpdatedVideos.clear();
    _adminUpdatedVideos.addAll(bufferVideos);
    notifyListeners();
  }

  Future<void> fetchAdminFinalisedVideos() async {
    List<String> documentIds = [];
    List<Video> bufferVideos = [];

    var videoList = await Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminFinalised)
        .getDocuments();

    if (videoList.documents.isEmpty) {
      _adminFinalisedVideos.clear();
      notifyListeners();
      return;
    }

    for (var doc in videoList.documents) documentIds.add(doc.documentID);

    List<List<String>> chunkedList = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      []
    ];
    int index = 0;
    int lastIndex = 0;
    int loopIteration = (documentIds.length / 10).toInt();
    for (int i = 0; i < loopIteration; i++) {
      chunkedList
          .elementAt(i)
          .addAll(documentIds.sublist(index, index + 9 + 1));
      index += 10;
      lastIndex = i;
    }

    chunkedList
        .elementAt(lastIndex + 1)
        .addAll(documentIds.sublist(index, documentIds.length));
    print('.................... OK 111 ..................');
    for (int i = 0; i < lastIndex + 1; i++) {
      if (chunkedList.elementAt(i).isNotEmpty) {
        var waitingVideos1 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
            .getDocuments();
        var videoDocs = waitingVideos1.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
    }
    print('.................... OK 222 ..................');
    if (chunkedList.elementAt(lastIndex + 1).length != 0) {
      var waitingVideos2 = await Firestore.instance
          .collection(Keys.videos)
          .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
          .getDocuments();
      var videoDocs = waitingVideos2.documents;
      for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
    }
    print('.................... OK 333 ..................');
    _adminFinalisedVideos.clear();
    _adminFinalisedVideos.addAll(bufferVideos);
    notifyListeners();
  }

  Future<void> assignNow(Video video) async {
    // 1. Remove adminWaiting
    // 2. Add adminAssigned
    // 3. Add instructorWaiting

    await Firestore.instance // 1
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminWaiting)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 2.
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminAssigned)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    await Firestore.instance // 3.
        .collection(Keys.instructors)
        .document(video.instructorId)
        .collection(Keys.instructorWaiting)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    _adminWaitingVideos
        .removeWhere((element) => element.videoId == video.videoId);
    //_adminAssignedVideos.add(video);

    notifyListeners();
  }

  Future<void> subscribeAdminWaitingVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];
    Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminWaiting)
        .snapshots()
        .listen((event) async {
      bufferVideos.clear();
      documentIds.clear();
      event.documents.forEach((element) {
        documentIds.add(element.documentID);
      });

      if (documentIds.isEmpty) {
        _adminWaitingVideos.clear();
        notifyListeners();
        return;
      }

      List<List<String>> chunkedList = [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        []
      ];
      int index = 0;
      int lastIndex = 0;
      int loopIteration = (documentIds.length / 10).toInt();
      for (int i = 0; i < loopIteration; i++) {
        chunkedList
            .elementAt(i)
            .addAll(documentIds.sublist(index, index + 9 + 1));
        index += 10;
        lastIndex = i;
      }

      chunkedList
          .elementAt(lastIndex + 1)
          .addAll(documentIds.sublist(index, documentIds.length));

      for (int i = 0; i < lastIndex + 1; i++) {
        if (chunkedList.elementAt(i).isNotEmpty) {
          var completedVideos1 = await Firestore.instance
              .collection(Keys.videos)
              .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
              .getDocuments();
          var videoDocs = completedVideos1.documents;
          for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
        }
      }
      if (chunkedList.elementAt(lastIndex + 1).length != 0) {
        var completedVideos2 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
            .getDocuments();
        var videoDocs = completedVideos2.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
      _adminWaitingVideos.clear();
      _adminWaitingVideos.addAll(bufferVideos);
      notifyListeners();
    });
  }

  Future<void> subscribeAdminAssignedVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];
    Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminAssigned)
        .snapshots()
        .listen((event) async {
      bufferVideos.clear();
      documentIds.clear();
      event.documents.forEach((element) {
        documentIds.add(element.documentID);
      });

      if (documentIds.isEmpty) {
        _adminAssignedVideos.clear();
        notifyListeners();
        return;
      }

      List<List<String>> chunkedList = [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        []
      ];
      int index = 0;
      int lastIndex = 0;
      int loopIteration = (documentIds.length / 10).toInt();
      for (int i = 0; i < loopIteration; i++) {
        chunkedList
            .elementAt(i)
            .addAll(documentIds.sublist(index, index + 9 + 1));
        index += 10;
        lastIndex = i;
      }

      chunkedList
          .elementAt(lastIndex + 1)
          .addAll(documentIds.sublist(index, documentIds.length));

      for (int i = 0; i < lastIndex + 1; i++) {
        if (chunkedList.elementAt(i).isNotEmpty) {
          var completedVideos1 = await Firestore.instance
              .collection(Keys.videos)
              .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
              .getDocuments();
          var videoDocs = completedVideos1.documents;
          for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
        }
      }
      if (chunkedList.elementAt(lastIndex + 1).length != 0) {
        var completedVideos2 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
            .getDocuments();
        var videoDocs = completedVideos2.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
      _adminAssignedVideos.clear();
      _adminAssignedVideos.addAll(bufferVideos);
      notifyListeners();
    });
  }

  Future<void> subscribeAdminUpdatedVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];
    Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminUpdated)
        .snapshots()
        .listen((event) async {
      bufferVideos.clear();
      documentIds.clear();
      event.documents.forEach((element) {
        documentIds.add(element.documentID);
      });

      if (documentIds.isEmpty) {
        _adminUpdatedVideos.clear();
        notifyListeners();
        return;
      }

      List<List<String>> chunkedList = [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        []
      ];
      int index = 0;
      int lastIndex = 0;
      int loopIteration = (documentIds.length / 10).toInt();
      for (int i = 0; i < loopIteration; i++) {
        chunkedList
            .elementAt(i)
            .addAll(documentIds.sublist(index, index + 9 + 1));
        index += 10;
        lastIndex = i;
      }

      chunkedList
          .elementAt(lastIndex + 1)
          .addAll(documentIds.sublist(index, documentIds.length));

      for (int i = 0; i < lastIndex + 1; i++) {
        if (chunkedList.elementAt(i).isNotEmpty) {
          var completedVideos1 = await Firestore.instance
              .collection(Keys.videos)
              .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
              .getDocuments();
          var videoDocs = completedVideos1.documents;
          for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
        }
      }
      if (chunkedList.elementAt(lastIndex + 1).length != 0) {
        var completedVideos2 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
            .getDocuments();
        var videoDocs = completedVideos2.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
      _adminUpdatedVideos.clear();
      _adminUpdatedVideos.addAll(bufferVideos);
      notifyListeners();
    });
  }

  Future<void> subscribeAdminFinalisedVideos() async {
    List<Video> bufferVideos = [];
    List<String> documentIds = [];
    Firestore.instance
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminFinalised)
        .snapshots()
        .listen((event) async {
      bufferVideos.clear();
      documentIds.clear();
      print('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
      print(event.documents.length);
      event.documents.forEach((element) {
        documentIds.add(element.documentID);
      });

      if (documentIds.isEmpty) {
        _adminFinalisedVideos.clear();
        notifyListeners();
        return;
      }

      List<List<String>> chunkedList = [
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        [],
        []
      ];
      int index = 0;
      int lastIndex = 0;
      int loopIteration = (documentIds.length / 10).toInt();
      for (int i = 0; i < loopIteration; i++) {
        chunkedList
            .elementAt(i)
            .addAll(documentIds.sublist(index, index + 9 + 1));
        index += 10;
        lastIndex = i;
      }

      chunkedList
          .elementAt(lastIndex + 1)
          .addAll(documentIds.sublist(index, documentIds.length));

      for (int i = 0; i < lastIndex + 1; i++) {
        if (chunkedList.elementAt(i).isNotEmpty) {
          var completedVideos1 = await Firestore.instance
              .collection(Keys.videos)
              .where(Keys.videoId, whereIn: chunkedList.elementAt(i))
              .getDocuments();
          var videoDocs = completedVideos1.documents;
          for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
        }
      }
      if (chunkedList.elementAt(lastIndex + 1).length != 0) {
        var completedVideos2 = await Firestore.instance
            .collection(Keys.videos)
            .where(Keys.videoId, whereIn: chunkedList.elementAt(lastIndex + 1))
            .getDocuments();
        var videoDocs = completedVideos2.documents;
        for (var i in videoDocs) bufferVideos.add(Video.fromMap(i.data));
      }
      _adminFinalisedVideos.clear();
      _adminFinalisedVideos.addAll(bufferVideos);
      notifyListeners();
    });
  }

  Future<void> cancelAssignment(Video video) async {
    // 1. Remove adminAssigned
    // 2. Add adminWaiting
    // 3. Remove instructorWaiting

    await Firestore.instance // 1
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminAssigned)
        .document(video.videoId)
        .delete();

    await Firestore.instance // 2
        .collection(Keys.admin)
        .document(Keys.videos)
        .collection(Keys.adminWaiting)
        .document(video.videoId)
        .setData({Keys.videoId: video.videoId});

    await Firestore.instance // 3
        .collection(Keys.instructors)
        .document(video.instructorId)
        .collection(Keys.instructorWaiting)
        .document(video.videoId)
        .delete();

    _adminAssignedVideos
        .removeWhere((element) => element.videoId == video.videoId);
    // _adminWaitingVideos.add(video);

    notifyListeners();
  }
}
