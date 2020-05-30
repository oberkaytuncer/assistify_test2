import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/style/font.dart';

class LineWithLightEffect extends StatelessWidget {
  final String text;
  final Color startLineColor;
  final Color endLineColor;
  final Color textColor;
  final double textSize;
  final String textFont;
  final AlignmentGeometry firstOffset;
  final AlignmentGeometry secondOffset;
  final double width;
  final double height;
  final List<double> stops;
  final double edgeValue;

  const LineWithLightEffect({
    Key key,
    @required this.text,
    this.startLineColor: Colors.white10,
    this.endLineColor: Colors.white,
    this.textColor: Colors.white,
    this.textSize: 16.0,
    this.textFont: MyFonts.fontNameMedium,
    this.firstOffset: const FractionalOffset(0.0, 0.0),
    this.secondOffset: const FractionalOffset(1.0, 1.0),
    this.width: 100.0,
    this.height: 1.0,
    this.stops: const [0.0, 1.0],
    this.edgeValue: 15,
  })  : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  startLineColor,
                  endLineColor,
                ],
                begin: firstOffset,
                end: secondOffset,
                stops: stops,
                tileMode: TileMode.clamp),
          ),
          width: width,
          height: height,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: edgeValue,
            right: edgeValue,
          ),
          child: Text(
            text,
            style: TextStyle(
                color: textColor, fontSize: textSize, fontFamily: textFont),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [
                  endLineColor,
                  startLineColor,
                ],
                begin: firstOffset,
                end: secondOffset,
                stops: stops,
                tileMode: TileMode.clamp),
          ),
          width: width,
          height: height,
        ),
      ],
    );
  }
}
