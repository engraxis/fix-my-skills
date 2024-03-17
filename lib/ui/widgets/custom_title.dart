import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  final bool showLeading;
  final String title;
  final Size size;
  CustomTitle({
    this.showLeading = false,
    @required this.title,
    @required this.size,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          showLeading
              ? Positioned(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: size.height,
                      width: size.height,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_sharp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              : Container(),
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
