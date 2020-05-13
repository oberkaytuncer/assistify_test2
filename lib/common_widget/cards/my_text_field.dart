import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/style/font.dart';

class MyTextFormField extends StatefulWidget {
  final String fontFamily;
  final double fontSize;
  final Color fontColor;
  final Color leadingIconColor;
  final TextEditingController textEditingController;
  final IconData leadingIcon;
  final String hintText;
  final IconData trealingIcon;
  final IconData trealingIconSlash;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final FormFieldSetter<String> onSaved;
  final String labelText;
  final String initialValue;
  final String errorText;
  bool obscureText;


  MyTextFormField({
    Key key,
    this.onSaved,
    this.obscureText: false,
    this.fontFamily: MyFonts.fontNameMedium,
    this.fontSize: 24.0,
    this.fontColor: Colors.black,
    this.textEditingController,
    this.initialValue,
    this.leadingIcon,
    this.leadingIconColor: Colors.black,
    @required this.hintText,
    this.labelText,
    this.trealingIcon,
    this.trealingIconSlash,
    this.focusNode,
    this.keyboardType: TextInputType.text,
    this.textCapitalization: TextCapitalization.none,
    this.errorText,
  }) : super(key: key);

  @override
  _MyTextFormField createState() => _MyTextFormField();
}



class _MyTextFormField extends State<MyTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
      child: TextFormField(
      
        initialValue: widget.initialValue,
        onSaved: widget.onSaved,
        
        focusNode: widget.focusNode,
        controller: widget.textEditingController,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        obscureText: widget.obscureText,
        style: TextStyle(
            fontFamily: widget.fontFamily,
            fontSize: widget.fontSize,
            color: widget.fontColor),
        decoration: InputDecoration(
          errorText: widget.errorText,
          border: UnderlineInputBorder(),
          icon: Icon(
            widget.leadingIcon,
            color: widget.leadingIconColor,
          ),
          hintText: widget.hintText,
          labelText: widget.labelText,
          hintStyle: TextStyle(
              fontFamily: widget.fontFamily, fontSize: widget.fontSize),
          suffixIcon: GestureDetector(
            onTap: _toogle,
       
            child: 
    
            Icon(
              widget.obscureText ? widget.trealingIcon : widget.trealingIconSlash,
              size: 14.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _toogle() {
    setState(() {
      widget.obscureText = !widget.obscureText;
    });
  }
}
