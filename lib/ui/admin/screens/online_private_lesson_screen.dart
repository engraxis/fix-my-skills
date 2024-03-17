import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

import '../../widgets/custom_container.dart';
import '../../widgets/background.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/custom_button.dart';

class OnlinePrivateLessonScreen extends StatefulWidget {
  @override
  _OnlinePrivateLessonScreenState createState() =>
      _OnlinePrivateLessonScreenState();
}

class _OnlinePrivateLessonScreenState extends State<OnlinePrivateLessonScreen> {
  bool _isDropDownClicked;

  @override
  void initState() {
    super.initState();
    _isDropDownClicked = false;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: mediaQuery.width * 0.05,
                  right: mediaQuery.width * 0.05,
                  top: mediaQuery.height * 0.03,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    CustomTitle(
                      showLeading: true,
                      title: 'Online Private Lesson',
                      size: Size(
                        mediaQuery.width,
                        mediaQuery.height * 0.05,
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.03),
                    CustomContainer(
                      buildBoundary: true,
                      containerWidth: mediaQuery.width * 0.7,
                      heightSpecified: true,
                      containerHeight: mediaQuery.height * 0.09,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isDropDownClicked = !_isDropDownClicked;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText(
                                text: 'Select Instructor',
                                isBold: true,
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.035),
                    if (_isDropDownClicked)
                      Container(
                        height: mediaQuery.height * 0.7,
                        width: mediaQuery.width * 0.7,
                        child: ListView.separated(
                            itemBuilder: (ctx, index) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDropDownClicked = false;
                                    });
                                  },
                                  child: CustomContainer(
                                    buildBoundary: true,
                                    containerWidth: mediaQuery.width * 0.7,
                                    heightSpecified: true,
                                    containerHeight: mediaQuery.height * 0.09,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                              child: Icon(
                                                  Icons.picture_in_picture)),
                                          SizedBox(width: 10),
                                          buildText(
                                              text: 'Name of instructor',
                                              isBold: true),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            separatorBuilder: (ctx, index) =>
                                SizedBox(height: 10),
                            itemCount: 10),
                      ),
                    if (!_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.05),
                    if (!_isDropDownClicked)
                      Container(
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: CalendarCarousel(
                          width: MediaQuery.of(context).size.width * 0.7,
                          headerTextStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 20),
                          headerMargin: EdgeInsets.all(0),
                          todayButtonColor: Colors.blue,
                          markedDateIconBorderColor: Colors.orange,
                          selectedDateTime: null,
                          selectedDayButtonColor: Colors.purple,
                          onDayPressed: (dateTime, _) {
                            print(dateTime.day);
                            setState(() {});
                          },
                        ),
                      ),
                    if (!_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.025),
                    if (!_isDropDownClicked)
                      CustomContainer(
                        buildBoundary: true,
                        heightSpecified: true,
                        containerWidth: mediaQuery.width * 0.7,
                        containerHeight: mediaQuery.height * 0.075,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: mediaQuery.height * 0.02),
                          child: buildText(
                            text: 'Select Time',
                            isBold: true,
                            isCenter: true,
                          ),
                        ),
                      ),
                    if (!_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.05),
                    if (!_isDropDownClicked)
                      CustomButton(
                        width: mediaQuery.width * 0.7,
                        text: 'CONFIRM BOOKING',
                        onPress: () {},
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text buildText({
    String text,
    bool isBold = false,
    bool isCenter = true,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );
  }

  Row buildRow(String textLeft, String textRight, double containerWidth,
      BuildContext context) {
    return Row(
      children: [
        Container(
          width: containerWidth * 0.5 - 10,
          child: Text(
            textLeft,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: containerWidth * 0.5 - 10,
          child: Text(
            textRight,
            maxLines: 4,
            style: TextStyle(color: Theme.of(context).primaryColor),
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }
}
