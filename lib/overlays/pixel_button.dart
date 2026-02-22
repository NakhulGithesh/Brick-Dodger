import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable pixel-art styled button used across all menus.
class PixelButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double fontSize;

  const PixelButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.width = 220,
    this.height = 52,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    // Pixel-art border colors derived from the base color
    final borderDark = HSLColor.fromColor(color)
        .withLightness(
            (HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0))
        .toColor();
    final borderLight = HSLColor.fromColor(color)
        .withLightness(
            (HSLColor.fromColor(color).lightness + 0.15).clamp(0.0, 1.0))
        .toColor();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          border: Border(
            top: BorderSide(color: borderLight, width: 4),
            left: BorderSide(color: borderLight, width: 4),
            bottom: BorderSide(color: borderDark, width: 4),
            right: BorderSide(color: borderDark, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.pressStart2p(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
