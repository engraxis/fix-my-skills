import 'package:flutter/material.dart';
import '../../helpers/common_functions.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final bool obscure, isReadOnly, showLeading;
  final TextInputType keyboardType;
  final IconData icon;
  final TextEditingController controller;
  final Widget trailling, leading;
  final Function onTap, validator;
  final int maxLines, minLines;
  final String initialValue;
  final Function onChangedFunction;
  final double height;

  CustomTextField({
    this.hint,
    @required this.validator,
    @required this.icon,
    @required this.controller,
    this.obscure = false,
    this.isReadOnly = false,
    this.showLeading = true,
    this.keyboardType,
    this.trailling,
    this.leading,
    this.onTap,
    this.maxLines = 1,
    this.minLines = 1,
    this.initialValue,
    this.onChangedFunction,
    this.height = 0.0,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure;

  @override
  void initState() {
    super.initState();

    obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
    );

    return Container(
      height: widget.height == 0.0 ? CommonFunctions.textFieldHeight(context) : widget.height,
      child: TextFormField(
        onChanged: widget.onChangedFunction,
        textCapitalization: TextCapitalization.sentences,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        obscureText: obscure,
        style: textStyle,
        readOnly: widget.isReadOnly,
        validator: widget.validator,
        onTap: widget.onTap,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          errorBorder: border,
          errorStyle: TextStyle(
            color: Theme.of(context).errorColor,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          hintStyle: textStyle,
          hintText: this.widget.hint,
          fillColor: Theme.of(context).primaryColor.withOpacity(0.3),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          prefixIcon: widget.showLeading
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: widget.leading == null
                      ? Icon(
                          widget.icon,
                          color: Colors.white,
                        )
                      : widget.leading,
                )
              : null,
          suffixIcon: widget.trailling == null
              ? widget.obscure
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      color: Color(0xff38006B),
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                    )
                  : null
              : widget.trailling,
        ),
      ),
    );
  }
}
