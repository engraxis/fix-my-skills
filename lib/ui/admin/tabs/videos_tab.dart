import 'package:flutter/material.dart';

import './videos_tab_waiting_tab.dart';
import './videos_tab_finalised_tab.dart';
import './videos_tab_assigned_tab.dart';
import './videos_tab_updated_tab.dart';
import '../../widgets/custom_buttonbar_button.dart';
import '../../widgets/custom_title.dart';

class VideosTab extends StatefulWidget {
  @override
  _VideosTabState createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  bool _isWaitingSelected;
  bool _isAssignedSelected;
  bool _isUpdatedSelected;
  bool _isFinalisedSelected;

  int index = 0;

  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _isWaitingSelected = true;
    _isAssignedSelected = false;
    _isUpdatedSelected = false;
    _isFinalisedSelected = false;
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
    final containerWidth = widthAfterPadding;
    final minus = 54;
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
                  buttonWidth: (containerWidth - minus) / 4,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  textColor: _isWaitingSelected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColor,
                  fillColor: _isWaitingSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                  text: 'WAITING',
                  onButtonPress: () {
                    _pageController.jumpToPage(0);
                    setState(() {
                      _isWaitingSelected = true;
                      _isAssignedSelected = false;
                      _isUpdatedSelected = false;
                      _isFinalisedSelected = false;
                    });
                  },
                ),
                CustomButtonBarButton(
                  buttonWidth: (containerWidth - minus) / 4,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  textColor: _isAssignedSelected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColor,
                  fillColor: _isAssignedSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                  text: 'ASSIGNED',
                  onButtonPress: () {
                    _pageController.jumpToPage(1);
                    _isWaitingSelected = false;
                    _isAssignedSelected = true;
                    _isUpdatedSelected = false;
                    _isFinalisedSelected = false;
                  },
                ),
                CustomButtonBarButton(
                  buttonWidth: (containerWidth - minus) / 4,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  textColor: _isUpdatedSelected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColor,
                  fillColor: _isUpdatedSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                  text: 'UPDATED',
                  onButtonPress: () {
                    _pageController.jumpToPage(2);
                    _isWaitingSelected = false;
                    _isAssignedSelected = false;
                    _isUpdatedSelected = true;
                    _isFinalisedSelected = false;
                  },
                ),
                CustomButtonBarButton(
                  buttonWidth: (containerWidth - minus) / 4,
                  buttonHeight: MediaQuery.of(context).size.height * 0.06,
                  textColor: _isFinalisedSelected
                      ? Theme.of(context).primaryColorDark
                      : Theme.of(context).primaryColor,
                  fillColor: _isFinalisedSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                  text: 'FINALIZED',
                  onButtonPress: () {
                    _pageController.jumpToPage(3);
                    _isWaitingSelected = false;
                    _isAssignedSelected = false;
                    _isUpdatedSelected = false;
                    _isFinalisedSelected = true;
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
                          _isWaitingSelected = true;
                          _isAssignedSelected = false;
                          _isUpdatedSelected = false;
                          _isFinalisedSelected = false;
                        });
                        break;
                      case 1:
                        setState(() {
                          _isWaitingSelected = false;
                          _isAssignedSelected = true;
                          _isUpdatedSelected = false;
                          _isFinalisedSelected = false;
                        });
                        break;
                      case 2:
                        setState(() {
                          _isWaitingSelected = false;
                          _isAssignedSelected = false;
                          _isUpdatedSelected = true;
                          _isFinalisedSelected = false;
                        });
                        break;
                      case 3:
                        setState(() {
                          _isWaitingSelected = false;
                          _isAssignedSelected = false;
                          _isUpdatedSelected = false;
                          _isFinalisedSelected = true;
                        });
                        break;
                      default:
                    }
                  });
                },
                children: <Widget>[
                  VideosTabWaitingTab(),
                  VideosTabAssignedTab(),
                  VideosTabUpdatedTab(),
                  VideosTabFinalisedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
