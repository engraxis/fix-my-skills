import 'package:flutter/material.dart';

import '../../ui/widgets/background.dart';
import '../../ui/widgets/custom_button.dart';
import '../../ui/widgets/custom_container.dart';
import '../../ui/widgets/custom_text_field.dart';
import '../../helpers/common_functions.dart';
import '../../helpers/auth_helper.dart';
import '../../res/static_info.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailCon;
  bool _isResetSent;
  bool _loadingFlag;

  @override
  void initState() {
    super.initState();

    _loadingFlag = false;
    _isResetSent = false;
    _emailCon = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    double mediaQueryWidth = MediaQuery.of(context).size.width;
    double mediaQueryHeight = MediaQuery.of(context).size.height;
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
                ),
                child: Form(
                  key: _formKey,
                  //search
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.03,
                            left: MediaQuery.of(context).size.width * 0.03,
                            right: MediaQuery.of(context).size.width * 0.03,
                          ),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: CustomContainer(
                                containerWidth: mediaQueryHeight * 0.06,
                                containerHeight: mediaQueryHeight * 0.06,
                                heightSpecified: true,
                                buildBoundary: false,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      child: Icon(
                                        Icons.arrow_back_ios_sharp,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: _Logo(),
                                ),
                                IconButton(
                                  icon: Container(),
                                  onPressed: null,
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.height * 0.06,
                          ),
                          child: _isResetSent == false
                              ? Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Text(
                                      "RESET PASSWORD",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColor,
                                        fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.055,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Center(
                                    child: Text(
                                      "Enter your email and we will send you password reset instructions",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColor,
                                        fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.04,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  CustomTextField(
                                    hint: 'Email',
                                    controller: _emailCon,
                                    validator: (String val) {
                                      if (val.isEmpty) return 'Enter email';
                                      return null;
                                    },
                                    icon: Icons.email,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: CustomButton(
                                      text: 'SEND',
                                      onPress: _loadingFlag
                                          ? null
                                          : () async {
                                              String email =
                                                  _emailCon.text.trim();
                                              if (email.isEmpty) {
                                                CommonFunctions.showToast(
                                                    context, 'Enter email');
                                                return;
                                              }

                                              bool flag = await AuthHelper()
                                                  .resetPassword(email);
                                              if (flag) {
                                                CommonFunctions.showToast(
                                                    context,
                                                    'Reset email has been sent to $email. You may need to check your junk folder.');
                                                setState(() {
                                                  _isResetSent = true;
                                                  _loadingFlag = true;
                                                });
                                              } else
                                                CommonFunctions.showToast(
                                                    context,
                                                    'Error in reseting password');
                                            },
                                    ),
                                  ),
                                ],
                              )
                              : Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Text(
                                      "SENT",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColor,
                                        fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.07,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Center(
                                    child: Text(
                                      "Follow instructions in email to reset your password",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColor,
                                        fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.04,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: CustomButton(
                                      text: 'GO TO LOGIN',
                                      onPress: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
