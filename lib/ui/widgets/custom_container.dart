import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final double containerWidth;
  final bool buildBoundary;
  final bool heightSpecified;
  final double containerHeight;
  final double hPadding;

  CustomContainer({
    @required this.child,
    this.containerWidth = 100,
    this.buildBoundary = true,
    this.heightSpecified = false,
    this.containerHeight = 100,
    this.hPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return heightSpecified
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            height: containerHeight,
            width: containerWidth,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(10),
              border: buildBoundary ? Border.all(color: Colors.white) : null,
            ),
            child: this.child,
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: hPadding),
            width: containerWidth,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(10),
              border: buildBoundary ? Border.all(color: Colors.white) : null,
            ),
            child: this.child,
          );
  }
}
