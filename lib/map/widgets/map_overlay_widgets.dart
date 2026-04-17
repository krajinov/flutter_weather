import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapPin extends StatelessWidget {
  const MapPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xBF11304A),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0x4D5A7D9A)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x82000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Icon(LucideIcons.mapPin, size: 18, color: Color(0xFF7CC4FF)),
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xBF12314C),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0x3D4A6A87)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Icon(LucideIcons.search, size: 18, color: Color(0xFFD6E4F2)),
      ),
    );
  }
}

class WeatherBlob extends StatelessWidget {
  final double left;
  final double top;
  final double width;
  final double height;
  final Color color;

  const WeatherBlob({
    super.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
