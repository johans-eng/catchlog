import 'package:flutter/material.dart';

class Outcomes {
  static const weggerend = 'Weggerend';
  static const boete50 = '50 euro boete';
  static const boete181 = '181 euro boete';
  static const politie = 'Politie';

  static const all = [weggerend, boete50, boete181, politie];

  static const colors = {
    weggerend: Color(0xFFFF9F0A),
    boete50: Color(0xFF64D2FF),
    boete181: Color(0xFF5856D6),
    politie: Color(0xFFFF453A),
  };

  static Color colorFor(String outcome) =>
      colors[outcome] ?? const Color(0xFF8E8E93);
}
