import 'package:flutter/material.dart';

import './videos_tab_waiting_tab.dart';
import './videos_tab_completed_tab.dart';
import '../../widgets/custom_buttonbar_button.dart';
import '../../widgets/custom_title.dart';

class VideosTab extends StatefulWidget {
  @override
  _VideosTabState createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  bool isWaitingSelected;
  bool isCompletedSelected;

  int index = 0;

  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    isWaitingSelected = true;
    isCompletedSelected = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final widthAfterPadding =
        mediaQuery.width - mediaQuery.width * 0.05 - mediaQuery.width * 0.05;
    final containerHeight = mediaQuery.height * 0.25;
    final containerWidth = widthAfterPadding;
    return //SafeArea(child: Text('OK'),);
        SafeArea(
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
              title: 'VIDEOS',
              size: Size(
                mediaQuery.width,
                mediaQuery.height * 0.05,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButtonBarButton(
                  buttonWidth: (containerWidth - 50) / 2,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  textColor: isWaitingSelected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColor,
                  fillColor: isWaitingSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                  text: 'WAITING',
                  onButtonPress: () {
                    _pageController.jumpToPage(0);
                    isWaitingSelected = true;
                    isCompletedSelected = false;
                  },
                ),
                CustomButtonBarButton(
                  buttonWidth: (containerWidth - 50) / 2,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  textColor: isCompletedSelected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColor,
                  fillColor: isCompletedSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                  text: 'COMPLETED',
                  onButtonPress: () {
                    _pageController.jumpToPage(1);
                    isWaitingSelected = false;
                    isCompletedSelected = true;
                  },
                ),
              ],
            ),
            SizedBox(height: mediaQuery.height * 0.008),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (pageIndex) {
                  setState(() {
                    switch (pageIndex) {
                      case 0:
                        setState(() {
                          isWaitingSelected = true;
                          isCompletedSelected = false;
                        });
                        break;
                      case 1:
                        setState(() {
                          isWaitingSelected = false;
                          isCompletedSelected = true;
                        });
                        break;
                      default:
                    }
                  });
                },
                children: <Widget>[
                  VideosTabWaitingTab(),
                  VideosTabCompletedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
