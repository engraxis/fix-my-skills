import 'package:flutter/material.dart';

class CustomTextFieldNoIcon extends StatefulWidget {
  final String hint;
  final Function validator, onSave, onChange;
  final double width, height;
  final int minLines, maxLines;
  final bool isFilled, isTextCenter;

  CustomTextFieldNoIcon({
    @required this.hint,
    @required this.validator,
    @required this.onSave,
    this.onChange,
    this.height,
    this.width,
    this.minLines = 1,
    this.maxLines = 10,
    this.isFilled = true,
    this.isTextCenter = false,
  });

  @override
  _CustomTextFieldNoIconState createState() => _CustomTextFieldNoIconState();
}

class _CustomTextFieldNoIconState extends State<CustomTextFieldNoIcon> {
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.white);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
    );

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(        
        style: textStyle,
        textCapitalization: TextCapitalization.sentences,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        validator: widget.validator,
        onChanged: widget.onChange,
        textAlign: widget.isTextCenter ? TextAlign.center : TextAlign.start,
        textAlignVertical: TextAlignVertical.bottom,
        onSaved: widget.onSave,
        decoration: InputDecoration(
          errorBorder: border,
          errorStyle: TextStyle(
            color: Theme.of(context).errorColor,
            fontWeight: FontWeight.bold,
          ),
          filled: widget.isFilled,
          hintStyle: textStyle,
          hintText: this.widget.hint,
          fillColor: Theme.of(context).primaryColor.withOpacity(0.3),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
