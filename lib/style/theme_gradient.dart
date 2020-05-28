import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Colors {

  const Colors();

  static const Color loginGradientStart = const  Color(0xFF3690ed)   ;   //Color(0xFF3690ed)
  static const Color loginGradientEnd = const Color(0xFF0047cc) ;          // Color(0xFF0047cc)

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

//0xFF3690ed