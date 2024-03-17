import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/video.dart';
import '../../models/instructor.dart';
import '../../helpers/common_functions.dart';
import '../../providers/instructors_provider.dart';

class CustomVideoThumbnailContainer extends StatelessWidget {
  final Video video;
  final String status;
  final String statusImagePath;
  bool showInstructor;

  CustomVideoThumbnailContainer({
    @required this.video,
    @required this.status,
    @required this.statusImagePath,
    this.showInstructor = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Instructor> _instructorsList =
        Provider.of<InstructorsProvider>(context, listen: true).instructorsList;

    return Stack(
      children: [
        CustomBlurredImage(
          waitingVideo: video,
        ),
        Positioned(
          child: Container(
            width: CommonFunctions.videoBoxSize(context).width * 0.4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status.isNotEmpty)
                  Text(
                    status,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(width: 10),
                if (statusImagePath.isNotEmpty)
                  Image.asset(
                    statusImagePath,
                    width: CommonFunctions.videoBoxSize(context).width * 0.06,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
          ),
          top: 10,
          right: 10,
        ),
        if (showInstructor)
          Positioned(
            child: Container(
              width: CommonFunctions.videoBoxSize(context).width * 0.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Image.network(
                      _instructorsList
                          .firstWhere(
                              (element) => element.uid == video.instructorId)
                          .pictureUrl,
                      width: CommonFunctions.videoBoxSize(context).width * 0.1,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    _instructorsList
                        .firstWhere(
                            (element) => element.uid == video.instructorId)
                        .name,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            top: video.isRejected ? 40 : 10,
            left: 10,
          ),
        if (video.isRejected)
          Positioned(
            child: Container(
              width: CommonFunctions.videoBoxSize(context).width * 0.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Admin Rejected',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            top: 10,
            left: 10,
          ),
        // : Positioned(
        //     child: Icon(
        //       Icons.brightness_1,
        //       color: Colors.yellow,
        //     ),
        //     top: 10,
        //     left: 10,
        //   ),
        Positioned(
          child: Icon(
            Icons.play_circle_filled,
            color: Theme.of(context).primaryColor,
            size: CommonFunctions.videoBoxSize(context).width * 0.15,
          ),
          top: CommonFunctions.videoBoxSize(context).height / 2 -
              (CommonFunctions.videoBoxSize(context).width * 0.15 / 2),
          left: CommonFunctions.videoBoxSize(context).width / 2 -
              (CommonFunctions.videoBoxSize(context).width * 0.15 / 2),
        ),
        Positioned(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              video.videoTitle.length > 60
                  ? video.videoTitle.substring(0, 50) + ' ...'
                  : video.videoTitle,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: CommonFunctions.videoBoxSize(context).height * 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          bottom: 10,
          width: CommonFunctions.videoBoxSize(context).width,
        ),
      ],
    );
  }
}

class CustomBlurredImage extends StatelessWidget {
  final Video waitingVideo;

  const CustomBlurredImage({
    @required this.waitingVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CommonFunctions.videoBoxSize(context).height,
      width: CommonFunctions.videoBoxSize(context).width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(waitingVideo.videoThumbnailUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 7),
          child: Container(
            height: CommonFunctions.videoBoxSize(context).height,
            width: CommonFunctions.videoBoxSize(context).width,
            child: Image.network(waitingVideo.videoThumbnailUrl),
          ),
        ),
      ),
    );
  }
}
