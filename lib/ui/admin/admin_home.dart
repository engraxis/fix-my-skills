import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './tabs/profile_tab.dart';
import './tabs/instructors_tab.dart';
import './tabs/chat_tab.dart';
import '../widgets/background.dart';
import '../admin/tabs/videos_tab.dart';
import '../../providers/instructors_provider.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int pageIndex = 0;

  @override
  void didChangeDependencies() {
    Provider.of<InstructorsProvider>(context, listen: false)
        .fetchInstructorsList()
        .then((value) => InstructorsProvider.instructorsLoading = false);
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
          InstructorsTab(),
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
              icon: Icon(Icons.people),
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
