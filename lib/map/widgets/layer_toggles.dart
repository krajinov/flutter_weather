import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LayerToggles extends StatelessWidget {
  final int activeLayer;
  final ValueChanged<int> onLayerChanged;

  const LayerToggles({
    super.key,
    required this.activeLayer,
    required this.onLayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final layers = ['Rain', 'Temperature', 'Wind'];

    return Row(
      children: List.generate(layers.length, (index) {
        final isActive = activeLayer == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => onLayerChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 36,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF0EA5E9)
                    : const Color(0xB80E2238),
                borderRadius: BorderRadius.circular(18),
                border: isActive
                    ? null
                    : Border.all(color: const Color(0x333D5971)),
              ),
              alignment: Alignment.center,
              child: Text(
                layers[index],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF031A2B)
                      : const Color(0xFFAFC2D3),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
