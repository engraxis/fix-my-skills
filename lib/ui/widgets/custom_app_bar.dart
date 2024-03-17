import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PreferredSize customAppBar({
  @required BuildContext context,
  String title,
  bool showIcon = true,
  bool showLeading = false,
  bool showTrailing = false,
}) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height * 0.1;
  return PreferredSize(
    preferredSize: Size(width, height),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/app_bar_background.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8.0,
            offset: Offset(
              0,
              0.1,
            ),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              showLeading
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_sharp),
                      onPressed: () => Navigator.pop(context),
                    )
                  : IconButton(icon: Container(), onPressed: null),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showIcon
                        ? Image.asset(
                            'assets/logo.png',
                            height: height * 0.8,
                            width: height * 0.8,
                          )
                        : Container(),
                    title == null
                        ? Container()
                        : Row(
                            children: <Widget>[
                              SizedBox(width: 5),
                              Text(
                                title.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.040,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              showTrailing
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                      ),
                      onPressed: null)
                  : Container(),
            ],
          ),
        ),
      ),
    ),
  );
}
