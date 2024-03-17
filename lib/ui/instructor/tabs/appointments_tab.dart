import 'package:fcg_admin_instructor/res/static_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel, EventList;
import 'package:provider/provider.dart';

import '../screens/chat_detail_screen.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/custom_container.dart';
import '../../../models/appointment.dart';
import '../../../providers/appointments_provider.dart';
import '../../../helpers/common_functions.dart';

class AppointmentsTab extends StatefulWidget {
  @override
  _AppointmentsTabState createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  bool _isRunningOnce;
  bool _isLoading;
  bool _isRefreshingAppointments;
  bool _isDaySelected = false;
  DateTime _selectedDateTime;

  @override
  void initState() {
    _selectedDateTime = DateTime.now();
    _isRunningOnce = true;
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isRunningOnce) {
      _isRunningOnce = false;
      _isRefreshingAppointments = false;
      _isLoading = true;
      await Provider.of<AppointmentsProvider>(context, listen: false)
          .fetchAppointments();
      setState(() {
        _isLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void reRunBuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    List<Appointment> _todayAppointments = [];
    EventList<Event> _appointmentDays = new EventList<Event>(events: {});

    if (!_isLoading) {
      List<Appointment> _appointments =
          Provider.of<AppointmentsProvider>(context, listen: true).appointments;

      _todayAppointments.addAll(_appointments.where((element) =>
          DateTime.parse(element.appointmentDayTime).day ==
              _selectedDateTime.day &&
          DateTime.parse(element.appointmentDayTime).month ==
              _selectedDateTime.month &&
          DateTime.parse(element.appointmentDayTime).year ==
              _selectedDateTime.year));

      _appointments.forEach((element) {
        DateTime dummy = DateTime.parse(element.appointmentDayTime);
        _appointmentDays.add(
            DateTime(dummy.year, dummy.month, dummy.day),
            new Event(
              date: DateTime(dummy.year, dummy.month, dummy.day),
              title: '',
              // icon: Container(
              //   // width: 30,
              //   // height: 30,
              //   decoration: BoxDecoration(
              //       color: Colors.transparent, shape: BoxShape.circle),
              //   child: Text(
              //     dummy.day.toString(),
              //     style: TextStyle(color: Colors.black, fontSize: 18),
              //   ),
              // ),
            ));
      });
    }

    return SafeArea(
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
              showLeading: false,
              title: 'APPOINTMENTS',
              size: Size(
                mediaQuery.width,
                mediaQuery.height * 0.05,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: CalendarCarousel<Event>(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 1,
                        todayButtonColor: Colors.blue,
                        markedDatesMap: _appointmentDays,
                        //markedDateShowIcon: true,
                        markedDateCustomTextStyle: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                        markedDateMoreCustomDecoration:
                            BoxDecoration(color: Colors.pink),
                        // markedDateIconMaxShown: 1,
                        markedDateMoreShowTotal: null,
                        //markedDateIconBuilder: (event) => event.icon,
                        // markedDateIconBorderColor: Colors.green,
                        markedDateIconMargin: 0.0,
                        markedDateIconOffset: 0.0,
                        selectedDateTime:
                            _isDaySelected ? _selectedDateTime : null,
                        selectedDayButtonColor: Colors.purple,
                        onDayPressed: (dateTime, _) => setState(() {
                          _selectedDateTime = dateTime;
                          _isDaySelected = true;
                        }),
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.03),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isRefreshingAppointments = true;
                        });
                        await Provider.of<AppointmentsProvider>(context,
                                listen: false)
                            .fetchAppointments();
                        setState(() {
                          _isRefreshingAppointments = false;
                        });
                      },
                      child: _isRefreshingAppointments
                          ? CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            )
                          : Text(
                              'Tap here to refresh',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.03),
                    ...buildAppointments(
                      _selectedDateTime,
                      context,
                      _todayAppointments,
                      reRunBuild,
                      _isLoading,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> buildAppointments(
  DateTime selectedDateTime,
  BuildContext context,
  List<Appointment> appointmentsToday,
  Function reRunBuild,
  bool loadingStatus,
) {
  final List<Widget> myWidgetList = [];
  _cancelAppointment(int index) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Warning!'),
        content: Text('Are you sure you want to cancel this appointment?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () async {
              CommonFunctions.showProgressDialog(
                  context, 'Deleting appointment ...');
              print(appointmentsToday.elementAt(index).userUid);
              await CommonFunctions.createNotification(
                  appointmentsToday.elementAt(index).userUid,
                  'Appointment Cancelled',
                  '${StaticInfo.currentUser.name} has cancelled appointment on ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.parse(appointmentsToday.elementAt(index).appointmentDayTime))}.');
              await Provider.of<AppointmentsProvider>(context, listen: false)
                  .cancelAppointment(appointmentsToday.elementAt(index));
              reRunBuild();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  if (loadingStatus) return [Center(child: CircularProgressIndicator())];
  if (appointmentsToday.length == 0)
    return [
      Center(
        child: Text(
          'No appointments for today.',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width * 0.06,
          ),
        ),
      )
    ];
  for (int index = 0; index < appointmentsToday.length; index++) {
    myWidgetList.add(
      Container(
        height: height * 0.45,
        width: width,
        child: LayoutBuilder(
          builder: (ctx, constraints) => CustomContainer(
            buildBoundary: true,
            heightSpecified: true,
            containerHeight: constraints.maxHeight,
            child: Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.02),
                Text(
                  DateFormat.yMMMEd().format(selectedDateTime),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: constraints.maxHeight * 0.08,
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).primaryColor,
                      size: constraints.maxWidth * 0.05,
                    ),
                    SizedBox(width: 10),
                    Text(
                      DateFormat.jm().format(DateTime.parse(appointmentsToday
                          .elementAt(index)
                          .appointmentDayTime)),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                CustomContainer(
                  buildBoundary: true,
                  heightSpecified: true,
                  containerHeight: constraints.maxHeight * 0.5,
                  containerWidth: constraints.maxWidth * 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CLIENT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          child: ClipOval(
                            child: Image.network(
                              appointmentsToday.elementAt(index).userPicUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          appointmentsToday.elementAt(index).userName,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ChatDetailScreen(
                                  appointmentsToday.elementAt(index).userUid,
                                  appointmentsToday.elementAt(index).userName),
                            ),
                          ),
                          child: CustomContainer(
                            containerWidth: constraints.maxWidth * 0.2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'Send Message',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Container(
                  width: constraints.maxWidth * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _cancelAppointment(index),
                        child: CustomContainer(
                          containerWidth: constraints.maxWidth * 0.45,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'CANCEL APPOINTMENT',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxWidth * 0.025,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (DateTime.now().isAfter(DateTime.parse(
                              appointmentsToday
                                  .elementAt(index)
                                  .appointmentDayTime))) {
                            CommonFunctions.showToast(context,
                                'Reminder not set. Meeting time already passed.');
                            return;
                          }
                          var fifteenMinsEarlier = DateTime.parse(
                                  appointmentsToday
                                      .elementAt(index)
                                      .appointmentDayTime)
                              .subtract(Duration(minutes: 15));
                          var oneHourEarlier = DateTime.parse(appointmentsToday
                                  .elementAt(index)
                                  .appointmentDayTime)
                              .subtract(Duration(minutes: 60));
                          if (fifteenMinsEarlier.isAfter(DateTime.now()) &&
                              oneHourEarlier.isBefore(DateTime.now())) {
                            CommonFunctions().localNotificationDelayed(
                              id: DateTime.now().minute,
                              meetingDateTime: DateTime.parse(appointmentsToday
                                  .elementAt(index)
                                  .appointmentDayTime),
                              delayMinutes: 10,
                              msgHeader: 'Meeting Reminder',
                              msgBody:
                                  'Meeting with ${appointmentsToday.elementAt(index).userName} in 10 mins.',
                            );
                            CommonFunctions.showToast(context,
                                'Reminder set for ten minutes earlier to meeting.');
                          } else if (oneHourEarlier.isAfter(DateTime.now())) {
                            CommonFunctions().localNotificationDelayed(
                              id: DateTime.now().minute,
                              meetingDateTime: DateTime.parse(appointmentsToday
                                  .elementAt(index)
                                  .appointmentDayTime),
                              delayMinutes: 60,
                              msgHeader: 'Meeting Reminder',
                              msgBody:
                                  'Meeting with ${appointmentsToday.elementAt(index).userName} in one hour',
                            );
                            CommonFunctions.showToast(context,
                                'Reminder set for one hour earlier to meeting.');
                          } else {
                            CommonFunctions.showToast(context,
                                'Reminder not set. Stay alert, your meeting is less than 15 mins.');
                          }
                        },
                        child: CustomContainer(
                          containerWidth: constraints.maxWidth * 0.3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'REMIND ME',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxWidth * 0.025,
                              ),
                            ),
                          ),
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
    );
    myWidgetList.add(
      SizedBox(height: 10),
    );
  }
  return myWidgetList;
}
