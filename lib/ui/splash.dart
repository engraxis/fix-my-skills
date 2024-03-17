import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './admin/admin_home.dart';
import './instructor/screens/availability_screen_start.dart';
import './instructor/instructor_home.dart';
import '../res/static_info.dart';
import '../helpers/auth_helper.dart';
import '../helpers/common_functions.dart';
import '../ui/auth/login.dart';
import '../ui/widgets/background.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      AuthHelper().getCurrentUser().then((user) {
        var page;
        if (user == null) {
          page = Login();
        } else {
          if (user.email == StaticInfo.ADMIN_EMAIL) {
            page = AdminHome();
          } else if (user.isInstructor) {
            page = user.availability ? InstructorHome() : AvailabilityScreenStart();
          } else {
            CommonFunctions.showToast(context, 'Instructor does not exist.');
            page = Login();
          }
        }
        Future.delayed(Duration(seconds: 2)).then((val) {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => page));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5));
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(),
          Center(
            child: Image.asset(
              'assets/app_logo_detailed.png',
              height: MediaQuery.of(context).size.width * 0.55,
            ),
          ),
        ],
      ),
    );
  }
}
