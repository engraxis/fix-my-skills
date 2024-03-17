import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../instructor_home.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_button_two.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/background.dart';
import '../../../providers/instructors_provider.dart';
import '../../../models/availability.dart';
import '../../../res/keys.dart';
import '../../../res/static_info.dart';
import '../../../helpers/common_functions.dart';

class AvailabilityScreenStart extends StatefulWidget {
  @override
  _AvailabilityScreenStartState createState() =>
      _AvailabilityScreenStartState();
}

class _AvailabilityScreenStartState extends State<AvailabilityScreenStart> {
  Map<String, String> _daysName;
  List<bool> _isDayAvailable;
  List<DateTime> _fromTime;
  List<DateTime> _toTime;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> availability;
  bool _isDataAvailable;
  bool _isRunningOnce;

  @override
  void initState() {
    super.initState();
    _isRunningOnce = true;
    _daysName = {
      WeekDays.dayNames[0]: 'Sunday',
      WeekDays.dayNames[1]: 'Monday',
      WeekDays.dayNames[2]: 'Tuesday',
      WeekDays.dayNames[3]: 'Wednesday',
      WeekDays.dayNames[4]: 'Thursday',
      WeekDays.dayNames[5]: 'Friday',
      WeekDays.dayNames[6]: 'Saturday',
    };

    _isDayAvailable = [];
    for (int i = 0; i < 7; i++) _isDayAvailable.add(false);

    _fromTime = [];
    for (int i = 0; i < 7; i++) _fromTime.add(null);

    _toTime = [];
    for (int i = 0; i < 7; i++) _toTime.add(null);

    _isDataAvailable = false;
  }

  @override
  void didChangeDependencies() {
    if (_isRunningOnce) {
      _isRunningOnce = false;
      Provider.of<InstructorsProvider>(context, listen: false)
          .fetchTimeTable(StaticInfo.currentUser.uid, context)
          .then((dataAvailable) {
        if (!dataAvailable) {
          setState(() {
            _isDataAvailable = true;
          });
          return;
        }
        availability = Provider.of<InstructorsProvider>(context, listen: false)
            .availability;
        for (int i = 0; i < 7; i++) {
          _isDayAvailable[i] =
              availability[WeekDays.dayNames[i]][Keys.isDayAvailable];
          _fromTime[i] = availability[WeekDays.dayNames[i]][Keys.from] != null
              ? DateTime.parse(availability[WeekDays.dayNames[i]][Keys.from]
                  .toDate()
                  .toString())
              : null;
          _toTime[i] = availability[WeekDays.dayNames[i]][Keys.to] != null
              ? DateTime.parse(availability[WeekDays.dayNames[i]][Keys.to]
                  .toDate()
                  .toString())
              : null;
        }
        setState(() {
          _isDataAvailable = true;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      body: !_isDataAvailable
          ? Container()
          : SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Background(),
                  SafeArea(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: mediaQuery.height * 0.03,
                      ),
                      width: mediaQuery.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/app_logo_detailed.png',
                            height: mediaQuery.width * 0.4,
                            width: mediaQuery.width * 0.4,
                          ),
                          SizedBox(height: mediaQuery.height * 0.02),
                          buildText(
                            text:
                                'Please select your availability day and time',
                            isBold: true,
                          ),
                          SizedBox(height: mediaQuery.height * 0.02),
                          CustomContainer(
                            buildBoundary: true,
                            heightSpecified: true,
                            containerWidth: mediaQuery.width * 0.8,
                            containerHeight: mediaQuery.height * 0.5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  buildText(
                                    text: 'AVAILABLE TIMINGS',
                                    isBold: true,
                                  ),
                                  Expanded(
                                    child: ListView.separated(
                                        itemBuilder: (ctx, index) => Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Switch(
                                                  activeColor: Colors.white,
                                                  activeTrackColor: Colors.grey,
                                                  inactiveThumbColor:
                                                      Colors.black,
                                                  inactiveTrackColor:
                                                      Colors.grey,
                                                  value: _isDayAvailable[index],
                                                  onChanged: (val) =>
                                                      setState(() {
                                                    _isDayAvailable[index] =
                                                        !_isDayAvailable[index];
                                                    if (!_isDayAvailable[
                                                        index]) {
                                                      _fromTime[index] = null;
                                                      _toTime[index] = null;
                                                    }
                                                  }),
                                                ),
                                                SizedBox(
                                                  width: mediaQuery.width *
                                                      0.8 *
                                                      0.23,
                                                  child: buildText(
                                                    text: _daysName[WeekDays
                                                        .dayNames[index]],
                                                    isCenter: false,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: mediaQuery.width *
                                                      0.8 *
                                                      0.22,
                                                  child: GestureDetector(
                                                    onTap: () => _isDayAvailable[
                                                            index]
                                                        ? _onSelectTime(
                                                            context,
                                                            'Select FROM time',
                                                            index)
                                                        : showSnackBar(
                                                            'First turn on respective day.',
                                                            context),
                                                    child: _isDayAvailable[
                                                            index]
                                                        ? buildTimeString(
                                                            _fromTime[index],
                                                            'From')
                                                        : buildTimeText(
                                                            text: 'From',
                                                            hPadding: 5,
                                                            vPadding: 10,
                                                          ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: mediaQuery.width *
                                                      0.8 *
                                                      0.28,
                                                  child: GestureDetector(
                                                    onTap: () => _isDayAvailable[
                                                            index]
                                                        ? _onSelectTime(
                                                            context,
                                                            'Select TO time',
                                                            index)
                                                        : showSnackBar(
                                                            'First turn on respective day.',
                                                            context),
                                                    child:
                                                        _isDayAvailable[index]
                                                            ? buildTimeString(
                                                                _toTime[index],
                                                                'To')
                                                            : buildTimeText(
                                                                text: 'To',
                                                                hPadding: 15,
                                                                vPadding: 10,
                                                              ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        separatorBuilder: (ctx, index) =>
                                            Container(
                                              width: mediaQuery.width * 0.8,
                                              height: 1,
                                              color: Colors.white,
                                            ),
                                        itemCount: 7),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: mediaQuery.height * 0.02),
                          buildText(
                            text: 'Set above schedule?',
                            isCenter: false,
                            isBold: true,
                          ),
                          SizedBox(height: mediaQuery.height * 0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: mediaQuery.width * 0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomButtonTwo(
                                  text: 'SKIP',
                                  width: mediaQuery.width * 0.6 * 1.5 / 3,
                                  onPress: () => Navigator.of(context)
                                      .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  InstructorHome()),
                                          (_) => false),
                                ),
                                CustomButton(
                                    text: 'CONTINUE',
                                    width: mediaQuery.width * 0.6 * 2.2 / 3,
                                    onPress: () async {
                                      for (int i = 0; i < 7; i++)
                                        if (_fromTime[i] == null &&
                                            _toTime[i] != null) {
                                          //This is possible only if a day is selected, is both of the times are null: that day will be turned off
                                          showSnackBar(
                                              _daysName[WeekDays.dayNames[i]] +
                                                  ' : Select both From time and To time.',
                                              context);
                                          return;
                                        }
                                      for (int i = 0; i < 7; i++)
                                        if (_fromTime[i] != null &&
                                            _toTime[i] == null) {
                                          //This is possible only if a day is selected, is both of the times are null: that day will be turned off
                                          showSnackBar(
                                              _daysName[WeekDays.dayNames[i]] +
                                                  ' : Select both From time and To time.',
                                              context);
                                          return;
                                        }

                                      for (int i = 0; i < 7; i++)
                                        if (_fromTime[i] == null &&
                                            _toTime[i] == null) {
                                          //Turn off a day: if both From and To are null/unselected
                                          _isDayAvailable[i] = false;
                                        }

                                      for (int i = 0; i < 7; i++)
                                        if (_isDayAvailable[i]) if (_toTime[i]
                                            .isBefore(_fromTime[i])) {
                                          //Check if To time is earlier than From time
                                          showSnackBar(
                                              _daysName[WeekDays.dayNames[i]] +
                                                  ' : To time should be later than From time.',
                                              context);
                                          return;
                                        }

                                      Availability().clearAvailability();

                                      for (int i = 0; i < 7; i++) {
                                        _isDayAvailable[i]
                                            ? Availability().addAvailability(
                                                WeekDays.dayNames[i],
                                                _fromTime[i],
                                                _toTime[i],
                                                true,
                                              )
                                            : Availability().addAvailability(
                                                WeekDays.dayNames[i],
                                                null,
                                                null,
                                                false,
                                              );
                                      }
                                      CommonFunctions.showProgressDialog(
                                          context, 'Updating Time Table ...');
                                      await Provider.of<InstructorsProvider>(
                                              context,
                                              listen: false)
                                          .updateAvailability(
                                              StaticInfo.currentUser.uid,
                                              Availability().availabilityList);
                                      await Provider.of<InstructorsProvider>(
                                              context,
                                              listen: false)
                                          .setInstructorAvailabilityFlag(
                                              StaticInfo.currentUser.uid);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  InstructorHome()),
                                          (_) => false);
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTimeString(DateTime time, String string) {
    if (time == null)
      return buildTimeText(
        text: string,
        vPadding: 10,
        hPadding: string == 'From' ? 5 : 15,
      );

    final formattedDate = DateFormat().add_jm().format(time);
    final retString = formattedDate;
    return buildTimeText(
      color: Colors.black,
      text: retString,
      vPadding: 10,
      hPadding: string == 'From' ? 5 : 15,
    );
  }

  showSnackBar(String a, BuildContext context) {
    SnackBar snackBar = SnackBar(
      content: Text(a),
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<void> _onSelectTime(
      BuildContext context, String helpText, int index) async {
    int _hour;
    int _minute;
    bool _isCancelled = false;
    await DatePicker.showTime12hPicker(context, currentTime: DateTime.now(),
        onConfirm: (time) {
      _hour = time.hour;
      _minute = time.minute;
    }, onCancel: () {
      _isCancelled = true;
    });

    if(_isCancelled) return;

    DateTime dummy = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _hour,
      _minute,
    );
    setState(() {
      helpText.contains('FROM')
          ? _fromTime[index] = dummy
          : _toTime[index] = dummy;
    });
  }

  Text buildText({
    String text,
    bool isBold = false,
    bool isCenter = true,
    int maxLines = 2,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: MediaQuery.of(context).size.width * 0.03,
      ),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );
  }

  Widget buildTimeText({
    String text,
    double hPadding = 0,
    double vPadding = 0,
    bool isBold = false,
    bool isCenter = true,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: vPadding,
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: MediaQuery.of(context).size.width * 0.03),
        textAlign: isCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
