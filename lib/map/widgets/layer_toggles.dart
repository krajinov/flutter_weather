import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    // Layers: Radar, Temperature, Wind, Clouds, Rainfall
    final layers = [
      {'name': l10n.radar, 'icon': LucideIcons.radioReceiver},
      {'name': l10n.temperature, 'icon': LucideIcons.thermometer},
      {'name': l10n.wind, 'icon': LucideIcons.wind},
      {'name': l10n.clouds, 'icon': LucideIcons.cloud},
      {'name': l10n.rainfall, 'icon': LucideIcons.cloudRain},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(layers.length, (index) {
          final isActive = activeLayer == index;
          return GestureDetector(
            onTap: () => onLayerChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 40,
              margin: EdgeInsets.only(right: index < layers.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF0EA5E9)
                    : const Color(0xB80E2238),
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? null
                    : Border.all(color: const Color(0x333D5971)),
                boxShadow: isActive
                    ? [
                        const BoxShadow(
                          color: Color(0x660EA5E9),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    layers[index]['icon'] as IconData,
                    size: 16,
                    color: isActive
                        ? const Color(0xFF031A2B)
                        : const Color(0xFFAFC2D3),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    layers[index]['name'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF031A2B)
                          : const Color(0xFFAFC2D3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
