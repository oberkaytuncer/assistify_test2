import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/common_widget/cards/my_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpCard extends StatefulWidget {
  final double elevationCard;
  final Color cardColor;
  final double widthCard;
  final double circularCard;

  final double widthLine;
  final double heightLine;
  final int itemNumber;

  const SignUpCard({
    Key key,
    this.elevationCard: 2.0,
    @required this.itemNumber,
    this.cardColor: Colors.white,
    this.circularCard: 8.0,
    this.widthCard: 300.0,

    this.widthLine: 250.0,
    this.heightLine: 1.0,
  }) : super(key: key);

  @override
  _SignUpCardState createState() => _SignUpCardState();
}

class _SignUpCardState extends State<SignUpCard> {
  @override
  Widget build(BuildContext context) {

  
    final heightCard = widget.itemNumber * 90.0;
    return Card(
      elevation: widget.elevationCard,
      color: widget.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.circularCard),
      ),
      child: Container(
        width: widget.widthCard,
        height: heightCard,
        child: Column(
          children: <Widget>[
            
            widget.itemNumber >= 4
                ? MyTextFormField(
                    leadingIcon: FontAwesomeIcons.userEdit,
                    hintText: 'Doldur Beni',
                  )
                : Container(),
             widget.itemNumber >=4 ? Container(
              width: widget.widthLine,
              height: widget.heightLine,
              color: Colors.grey[400],
            ) : Container(),
            widget.itemNumber >= 3
                ? MyTextFormField(
                  textCapitalization: TextCapitalization.words,
                    leadingIcon: FontAwesomeIcons.user,
                    hintText: 'İsim Soyisim',
                  )
                : Container(),
            widget.itemNumber >=3 ? Container(
              width: widget.widthLine,
              height: widget.heightLine,
              color: Colors.grey[400],
            ) : Container(),
            widget.itemNumber >=2 ? MyTextFormField(
              keyboardType: TextInputType.emailAddress,
              leadingIcon: FontAwesomeIcons.envelope,
              hintText: 'Mail',
            ) : Container(),
           widget.itemNumber >=2 ? Container(
              width: widget.widthLine,
              height: widget.heightLine,
              color: Colors.grey[400],
            ) : Container(),
            MyTextFormField(
              trealingIcon: FontAwesomeIcons.eye ,

              leadingIcon: FontAwesomeIcons.lock,
              hintText: 'Şifre',
            ),
          ],
        ),
      ),
    );
  }
}
