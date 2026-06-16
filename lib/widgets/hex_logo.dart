import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import 'hex_clipper.dart';

class HexLogo extends StatelessWidget {
  const HexLogo({
    super.key,
    required this.size,
    required this.gradient,
    required this.mono,
  });

  final double size;
  final Gradient gradient;
  final String mono;

  static const _borderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primaryDark],
  );

  @override
  Widget build(BuildContext context) {
    final innerSize = size * (48 / 54);
    final fontSize = size * (15 / 54);

    return ClipPath(
      clipper: HexClipper(),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(gradient: _borderGradient),
        alignment: Alignment.center,
        child: ClipPath(
          clipper: HexClipper(),
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(gradient: gradient),
            alignment: Alignment.center,
            child: Text(
              mono,
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppHexLogo extends StatelessWidget {
  const AppHexLogo({super.key, this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    final innerSize = size * (40 / 46);
    return ClipPath(
      clipper: HexClipper(),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryLight, AppColors.primaryDark],
          ),
        ),
        alignment: Alignment.center,
        child: ClipPath(
          clipper: HexClipper(),
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10182B), Color(0xFF0A0E1A)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'LOL',
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w700,
                fontSize: size * (13 / 46),
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
