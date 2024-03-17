import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './ui/splash.dart';
import './providers/videos_provider.dart';
import './providers/instructors_provider.dart';
import './providers/appointments_provider.dart';
import './helpers/common_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  WidgetsFlutterBinding.ensureInitialized();

  // Following is the code for one signal notifications
  //Remove this method to stop OneSignal Debugging
  // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId("${CommonFunctions.OS_APP_ID}"/*, iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: false
  }*/);
  /*OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);
  */

  await OneSignal.shared
      .promptUserForPushNotificationPermission(fallbackToSettings: true);

  // <Following is the code for local notifications
  WidgetsFlutterBinding.ensureInitialized();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  iosInitializationSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          CommonFunctions.onDidReceiveLocalNotification);
  initializationSettings = InitializationSettings(
      android: androidInitializationSettings, iOS: iosInitializationSettings);
  await CommonFunctions.flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: CommonFunctions.onSelectNotification);
  // />
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => VideosProvider()),
        ChangeNotifierProvider(create: (ctx) => AppointmentsProvider()),
        ChangeNotifierProvider(create: (ctx) => InstructorsProvider()),
      ],
      builder: (ctx, _) => MaterialApp(
        theme: ThemeData(
          fontFamily: 'Montserrat',
          primaryColor: Colors.white, //white
          primaryColorDark: Colors.black,
          accentColor: Colors.white30, //white30
          errorColor: Colors.red,
          // cursorColor: Colors.orange,
          //         primaryColor: Color(0xff1C6290),
          // primaryColorDark: Color(0xff094C77),
          // accentColor: Colors.white,
          // cursorColor: Colors.white
        ),
        debugShowCheckedModeBanner: false,
        home: Splash(),
      ),
    );
  }
}
