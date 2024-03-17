import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './tabs/videos_tab.dart';
import '../widgets/background.dart';
import './tabs/profile_tab.dart';
import './tabs/appointments_tab.dart';
import './tabs/chat_tab.dart';

class InstructorHome extends StatefulWidget {
  @override
  _InstructorHomeState createState() => _InstructorHomeState();
}

class _InstructorHomeState extends State<InstructorHome> {
  int pageIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: customAppBar(
      //   context: context,
      //   title: 'Fly Cheer Gear',
      //   showIcon: false,
      //   showLeading: false,
      //   showTrailing: false,
      // ),
      body: Stack(
        children: <Widget>[
          Background(),
          SafeArea(
            child: IndexedStack(
              index: pageIndex,
              children: [
                VideosTab(),
                AppointmentsTab(),
                ChatTab(),
                ProfileTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3),
        child: BottomNavigationBar(
          //elevation: 20,
          currentIndex: pageIndex,
          onTap: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.black,
          selectedIconTheme: IconThemeData(
            color: Colors.blue,
            size: 40,
          ),
          items: [
            // BottomNavigationBarItem(
            //   icon: Image.asset(
            //     'assets/favourites_tab.png',
            //   ),
            //   title: Container(),
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              title: Container(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              title: Container(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              title: Container(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
