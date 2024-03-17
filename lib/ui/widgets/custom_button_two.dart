import 'package:flutter/material.dart';

class CustomButtonTwo extends StatelessWidget {
  final String text;
  final Function onPress;
  final Color color;
  final bool showIcon;
  final IconData icon;
  final double width;
  final double vPadding;
  final Color textColor;

  CustomButtonTwo({
    @required this.text,
    @required this.onPress,
    this.color,
    this.showIcon = false,
    this.icon,
    this.width = 0,
    this.vPadding = 20,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      child: showIcon
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                SizedBox(width: 5),
                Text(
                  text,
                  style: TextStyle(
                      color: textColor == null
                          ? Theme.of(context).primaryColorDark
                          : textColor,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          : Text(
              text,
              style: TextStyle(
                color: textColor == null
                    ? Theme.of(context).primaryColorDark
                    : textColor,
                fontSize: MediaQuery.of(context).size.width * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
      onPressed: onPress,
      splashColor: Theme.of(context).primaryColor,
      minWidth: width == 0 ? double.infinity : width,
      padding: EdgeInsets.symmetric(vertical: vPadding),
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      focusColor: Theme.of(context).primaryColor,
      disabledColor: Theme.of(context).primaryColor,
    );
  }
}
