import 'package:flutter/material.dart';

class CustomButtonBarButton extends StatelessWidget {
  final String text;
  final double buttonWidth;
  final double buttonHeight;
  final Function onButtonPress;
  final Color fillColor;
  final Color textColor;

  CustomButtonBarButton({
    this.text,
    this.buttonWidth = 100,
    this.buttonHeight = 100,
    this.onButtonPress,
    this.fillColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      width: buttonWidth,
      child: FlatButton(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        color: fillColor,
        onPressed: onButtonPress,
        child: Text(
          text,
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width * 0.02),
        ),
      ),
    );
  }
}
