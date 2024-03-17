import 'package:fcg_admin_instructor/ui/instructor/instructor_home.dart';
import 'package:flutter/material.dart';

import './reset_password.dart';
import '../admin/admin_home.dart';
import '../../helpers/auth_helper.dart';
import '../../res/keys.dart';
import '../../res/static_info.dart';
import '../../helpers/common_functions.dart';
import '../../ui/widgets/background.dart';
import '../../ui/widgets/custom_button.dart';
import '../../ui/widgets/custom_text_field.dart';
import '../instructor/screens/availability_screen_start.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailCon, _passwordCon;

  bool _loadingFlag;

  @override
  void initState() {
    super.initState();

    _loadingFlag = false;
    _emailCon = TextEditingController();
    _passwordCon = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height -
                      (MediaQuery.of(context).padding.top +
                          MediaQuery.of(context).padding.bottom),
                  maxWidth: MediaQuery.of(context).size.width - 10,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      _Logo(),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.1,
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'INSTRUCTOR',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            CustomTextField(
                              hint: 'Email',
                              controller: _emailCon,
                              validator: (String val) {
                                if (val.isEmpty) return 'Enter email';
                                return null;
                              },
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            CustomTextField(
                              hint: 'Password',
                              controller: _passwordCon,
                              validator: (String val) {
                                if (val.isEmpty) return 'Enter password';
                                return null;
                              },
                              icon: Icons.vpn_key,
                              obscure: true,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => ResetPassword())),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  child: Text(
                                    "forgot password?",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            CustomButton(
                              text: 'LOGIN',
                              onPress: _loadingFlag
                                  ? null
                                  : () {
                                      if (_formKey.currentState.validate()) {
                                        CommonFunctions.showProgressDialog(
                                            context, 'Logging in ...');
                                        _login();
                                      }
                                    },
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Made by ',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Flycheergear',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _login() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _loadingFlag = true;
    });
    var result = await AuthHelper()
        .login(_emailCon.text.trim().toLowerCase(), _passwordCon.text);
        print('************************* $result');
    setState(() {
      _loadingFlag = false;
    });

    if (result == null) {
      var page;
      if (_emailCon.text.trim().toLowerCase() == StaticInfo.ADMIN_EMAIL)
        {print('okkkkkkkkkkkkkkkkkkk 02');
          page = AdminHome();}
      else
        page = StaticInfo.currentUser.isInstructor
            ? StaticInfo.currentUser.availability
                ? InstructorHome()
                : AvailabilityScreenStart()
            : Login();

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => page), (_) => false);
    } else if (result == AuthErrors.ERROR_USER_NOT_FOUND) {
      Navigator.of(context).pop();
      CommonFunctions.showToast(context, 'User does not exist.');
    } else if (result == AuthErrors.ERROR_WRONG_PASSWORD) {
      Navigator.of(context).pop();
      CommonFunctions.showToast(context, 'Wrong password.');
    } else {
      Navigator.of(context).pop();
      CommonFunctions.showToast(
          context, 'Sorry, invalid login credentials. Try again.');
    }
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.asset(
          'assets/app_logo_detailed.png',
          height: MediaQuery.of(context).size.width * 0.24,
        ),
      ],
    );
  }
}
