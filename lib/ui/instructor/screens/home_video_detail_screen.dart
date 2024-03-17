import 'package:flutter/material.dart';

import '../../widgets/custom_container.dart';
import '../../widgets/background.dart';
import '../../widgets/custom_title.dart';

class HomeVideoDetailScreen extends StatefulWidget {
  @override
  _HomeVideoDetailScreenState createState() => _HomeVideoDetailScreenState();
}

class _HomeVideoDetailScreenState extends State<HomeVideoDetailScreen> {
  int totalPosts = 5;
  List<bool> isPremium;
  bool _isCommentClicked;

  @override
  void initState() {
    super.initState();
    _isCommentClicked = false;

    isPremium = [];
    for (int i = 0; i < totalPosts; i++) isPremium.add(true);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final radius = MediaQuery.of(context).size.height * 0.016;
    final widthAfterPadding =
        mediaQuery.width - mediaQuery.width * 0.05 - mediaQuery.width * 0.05;
    final containerHeight = mediaQuery.height * 0.25;
    final containerWidth = widthAfterPadding;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(),
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
                    showLeading: true,
                    title: 'FEATURED VIDEOS',
                    size: Size(
                      mediaQuery.width,
                      mediaQuery.height * 0.05,
                    ),
                  ),
                  SizedBox(height: mediaQuery.height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mediaQuery.width * 0.2),
                    child: buildText(
                      text:
                          'How work with green sheet effect. Learn Cinema tricks',
                      isBold: true,
                    ),
                  ),
                  SizedBox(height: mediaQuery.height * 0.03),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          radius,
                        ),
                        child: Container(
                          width: containerWidth,
                          height: containerHeight,
                          color: Colors.red,
                          child: Image.asset('assets/logo.png'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mediaQuery.height * 0.03),
                  Expanded(
                    child: _isCommentClicked
                        ? CustomContainer(
                            buildBoundary: true,
                            containerWidth: containerWidth,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        child: Icon(Icons.picture_in_picture),
                                      ),
                                      SizedBox(width: 10),
                                      buildText(
                                        text: 'Justin Willis',
                                        isBold: true,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  buildText(
                                    text:
                                        'lksjd flksdflksue slkdj dlksj hslk sljf ldksfjslkdfj l;sdfj ;lsdjf;lskdjflsjf lsdkfj lskjfls jflsjf lsjf lsjdflsdjfk dklfjoi4uroaerh asldvn c bnioruoewiurihas djvowp4ehrivknc oirwnvdk; rhibjvl kggjiofbhkn; vdfjoib;nvk kjdvboi  sljwlkjsdf l j  l',
                                    isCenter: false,
                                    maxLines: 10,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemBuilder: (ctx, index) => GestureDetector(
                              onTap: () =>
                                  setState(() => _isCommentClicked = true),
                              child: CustomContainer(
                                buildBoundary: true,
                                heightSpecified: true,
                                containerWidth: containerWidth,
                                containerHeight: mediaQuery.height * 0.17,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            child:
                                                Icon(Icons.picture_in_picture),
                                          ),
                                          SizedBox(width: 10),
                                          buildText(
                                            text: 'Justin Willis',
                                            isBold: true,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      buildText(
                                        text:
                                            'lksjd flksdflksue slkdj dlksj hslk sljf ldksfjslkdfj l;sdfj ;lsdjf;lskdjflsjf lsdkfj lskjfls jflsjf lsjf lsjdflsdjfk dklfjoi4uroaerh asldvn c bnioruoewiurihas djvowp4ehrivknc oirwnvdk; rhibjvl kggjiofbhkn; vdfjoib;nvk kjdvboi  sljwlkjsdf l j  l',
                                        isCenter: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            separatorBuilder: (ctx, index) =>
                                SizedBox(height: 10),
                            itemCount: 10,
                          ),
                  ),
                  SizedBox(height: mediaQuery.height * 0.03),
                  _isCommentClicked
                      ? GestureDetector(
                          onTap: () =>
                              setState(() => _isCommentClicked = false),
                          child: CustomContainer(
                            buildBoundary: true,
                            containerWidth: containerWidth,
                            heightSpecified: true,
                            containerHeight: mediaQuery.height * 0.08,
                            child: Center(
                              child: buildText(
                                text: '<    Show all comments',
                                isBold: true,
                              ),
                            ),
                          ),
                        )
                      : CustomContainer(
                          buildBoundary: true,
                          containerWidth: containerWidth,
                          heightSpecified: true,
                          containerHeight: mediaQuery.height * 0.08,
                          child: Center(
                            child: buildText(
                              text: 'Type comment here',
                              isBold: true,
                            ),
                          ),
                        ),
                ],
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
    int maxLines = 2,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );
  }
}
