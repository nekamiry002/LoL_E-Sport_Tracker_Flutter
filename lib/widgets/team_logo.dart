import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'hex_logo.dart';

/// Shows the team's real logo when available, falls back to HexLogo otherwise.
/// TBD / empty imageUrl always show the hexagon.
class TeamLogo extends StatelessWidget {
  const TeamLogo({super.key, required this.team, required this.size});

  final TeamData team;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = team.imageUrl;
    if (url.isEmpty || team.id == 'TBD') {
      return HexLogo(size: size, gradient: team.gradient, mono: team.mono);
    }
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            HexLogo(size: size, gradient: team.gradient, mono: team.mono),
      ),
    );
  }
}
