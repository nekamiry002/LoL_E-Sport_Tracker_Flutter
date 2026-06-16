import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF12192B);
  static const Color surfaceDeep = Color(0xFF0C1322);

  static const Color primary = Color(0xFFC89B3C);
  static const Color primaryLight = Color(0xFFE3C26B);
  static const Color primaryDark = Color(0xFF7A5E1F);

  static const Color accent = Color(0xFF1E90FF);

  static const Color textPrimary = Color(0xFFE6EAF2);
  static const Color textSecondary = Color(0xFF8A93A8);
  static const Color textMuted = Color(0xFF5B6478);
  static const Color textDim = Color(0xFF7A8294);
  static const Color textSubtle = Color(0xFFC7CEDB);

  static const Color liveRed = Color(0xFFE2454A);
  static const Color liveRedLight = Color(0xFFFF5A5F);

  static const Color win = Color(0xFF2BAE66);
  static const Color support = Color(0xFFB98BFF);

  static const Color border = Color(0x0FFFFFFF);
  static const Color borderLight = Color(0x12FFFFFF);

  static const Color lckColor = Color(0xFFE3C26B);
  static const Color lplColor = Color(0xFFFF5A5F);
  static const Color lecColor = Color(0xFF1E90FF);
  static const Color lcsColor = Color(0xFF2BAE66);

  static Color leagueColor(String league) => switch (league) {
        'LCK' => lckColor,
        'LPL' => lplColor,
        'LEC' => lecColor,
        'LCS' => lcsColor,
        _ => primary,
      };
}
