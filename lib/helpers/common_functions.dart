import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gallery_saver/gallery_saver.dart';

import '../ui/widgets/custom_button.dart';
import '../models/video.dart';
import '../res/keys.dart';

class CommonFunctions {
  static const String DOWNLOAD_PORT_KEY = 'downloadPortKey01S412584';
  static const String OS_APP_ID =
      'c80bc3df-bc63-4284-82a0-46bc3b3ca5af'; //OS OneSignal
  static const String OS_REST_API_KEY =
      'NWQyYjhkY2ItM2Y1Ni00MTJkLWI1YmItZmNjMjczN2QzZDQ3';

  // <START---------------------------- Flutter Local Notifications
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> onSelectNotification(String payLoad) async {
    if (payLoad != null) {
      print(payLoad);
    }
    // we can set navigator to navigate another screen
  }

  static Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  Future<void> instantLocalNotification(String header, String body) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.high,
            importance: Importance.max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, header, body, notificationDetails);
  }

  Future<void> localNotificationDelayed(
      {int id,
      String msgHeader,
      String msgBody,
      DateTime meetingDateTime,
      int delayMinutes}) async {
    var timeDelayed = meetingDateTime.subtract(Duration(minutes: delayMinutes));
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'second Channel title', 'second channel body',
            priority: Priority.high,
            importance: Importance.max,
            ticker: 'test');

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    await flutterLocalNotificationsPlugin.schedule(
        id, msgHeader, msgBody, timeDelayed, notificationDetails);
  }
  // <END---------------------------- Flutter Local Notifications

  static downloadingCallback(id, status, progress) {
    SendPort sendPort =
        IsolateNameServer.lookupPortByName(CommonFunctions.DOWNLOAD_PORT_KEY);
    sendPort.send([id, status, progress]);
  }

  static createNotification(
      String receiverUid, String msgHeader, String msgBody) async {
    var res = await http.post(
      'https://onesignal.com/api/v1/notifications',
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Basic ${CommonFunctions.OS_REST_API_KEY}"
      },
      body: json.encode({
        'app_id': "${CommonFunctions.OS_APP_ID}",
        'headings': {"en": msgHeader},
        'contents': {"en": msgBody},
//        'included_segments': ["All"],
        "filters": [
          {"field": "tag", "key": receiverUid, "relation": "=", "value": "yes"}
        ],
      }),
    );
    final String secondOneSignalAppID = "df135383-ae34-4c54-9973-c688df65178f";
    final String secondOneSignalRestAPIKey =
        "NWQ4NWM2ZWItNzMxMi00ZTNiLThjNGEtNDA5M2YwNDllOTNl";
    res = await http.post(
      'https://onesignal.com/api/v1/notifications',
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Basic $secondOneSignalRestAPIKey"
      },
      body: json.encode({
        'app_id': secondOneSignalAppID,
        'headings': {"en": msgHeader},
        'contents': {"en": msgBody},
        "filters": [
          {"field": "tag", "key": receiverUid, "relation": "=", "value": "yes"}
        ],
      }),
    );
  }

  static Future<bool> yesNoDialog(BuildContext context, String title) async {
    bool ret = false;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Color(0xFF3290E3),
          title: Text(title),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomButton(
                      text: 'Cancel',
                      width: MediaQuery.of(context).size.width * 0.7 / 3,
                      onPress: () => Navigator.of(context).pop(false),
                    ),
                    CustomButton(
                      text: 'Yes',
                      width: MediaQuery.of(context).size.width * 0.7 / 3,
                      onPress: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) => ret = value);
    return ret;
  }

  static void launchUrl(String url, BuildContext context) async {
    url = url.trim();
    url = url.toLowerCase();
    if (await canLaunch(url))
      launch(url);
    else
      CommonFunctions.showToast(context, 'Video URL is broken.');
  }

  static Future<String> showTextInputDialog(
      BuildContext context, String title, String initialValue) async {
    String ret = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        String urlString;
        return AlertDialog(
          backgroundColor: Color(0xFF3290E3),
          title: Text(title),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    initialValue: initialValue,
                    style: TextStyle(fontSize: 14),
                    maxLines: null,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => urlString = val,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomButton(
                        text: 'Cancel',
                        width: MediaQuery.of(context).size.width * 0.7 / 3,
                        onPress: () => Navigator.of(context).pop(null),
                      ),
                      CustomButton(
                        text: 'Ok',
                        width: MediaQuery.of(context).size.width * 0.7 / 3,
                        onPress: () => Navigator.of(context).pop(urlString),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) => ret = value);
    return ret;
  }

  static void downloadVideo(Video video, BuildContext context,
      {bool downloadOriginal = true, bool downloadUpdated = false}) async {
    final status = await Permission.storage.request();

    String path = Platform.isAndroid
        ? (await getExternalStorageDirectory()).path
        : (await getApplicationDocumentsDirectory()).absolute.path;
    if (status.isGranted) {
      final videoId = downloadOriginal ? video.videoId : video.upDatedVideoId;

      String vidName = downloadOriginal
          ? video.videoTitle + ' - raw video.mp4'
          : video.videoTitle + ' - analysed video.mp4';
      String fullPath = path + '/' + vidName;
      final File tempFile = File(fullPath);
      try {
        firebase_storage.StorageReference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child(video.userId)
            .child(Keys.videos)
            .child(videoId);

        CommonFunctions.showProgressDialog(context,
            'Downloading video ...\nThis may take a while depending upon video size.\nVideo will download in the background.');
        await Future.delayed(Duration(seconds: 3));
        Navigator.of(context).pop();
        await ref.writeToFile(tempFile).future;
        await tempFile.create();
        CommonFunctions.showToast(context, 'Downloading finished.');
        print(fullPath);
        await Future.delayed(Duration(seconds: 1));
        await GallerySaver.saveVideo(fullPath, albumName: 'FCG')
            .then((bool value) => print(value.toString()));
        CommonFunctions().instantLocalNotification(
            'Video Downloaded', 'View ${video.videoTitle} in your gallery.');
      } catch (e) {
        print(e.toString());
        CommonFunctions.showToast(context, 'Error downloading file');
      }
      /* final taskId = await FlutterDownloader.enqueue(
        url: downloadOriginal
            ? video.rawVideoUrl
            : downloadUpdated
                ? video.updatedVideoUrl
                : video.analysedVideoUrl,
        savedDir: path,
        fileName: downloadOriginal
            ? video.videoTitle + ' - raw video.mp4'
            : video.videoTitle + ' - updated video.mp4',
        
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );*/
    } else {
      CommonFunctions.showToast(context, 'Permission denied.');
    }
  }

  static void showToast(BuildContext context, String msg, [int duration = 3]) =>
      Toast.show(msg, context,
          duration: duration,
          backgroundColor: Colors.white,
          textColor: Colors.black);

  static showProgressDialog(BuildContext context, String title) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Container(
              height: MediaQuery.of(context).size.height / 15,
              width: MediaQuery.of(context).size.width / 10,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Size videoBoxSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).size.width * 0.05 -
        MediaQuery.of(context).size.width * 0.05;
    double height = width / 1.8;
    return Size(width, height);
  }

  static double textFieldHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.07;
}
