import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapLayerChips extends StatelessWidget {
  final int activeLayer;
  final ValueChanged<int> onLayerChanged;

  const MapLayerChips({
    super.key,
    required this.activeLayer,
    required this.onLayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Layers: Radar, Temperature, Wind, Clouds, Pressure
    final layers = [
      {'name': l10n.radar, 'icon': LucideIcons.radioReceiver},
      {'name': l10n.temperature, 'icon': LucideIcons.thermometer},
      {'name': l10n.wind, 'icon': LucideIcons.wind},
      {'name': l10n.clouds, 'icon': LucideIcons.cloud},
      {'name': l10n.pressure, 'icon': LucideIcons.gauge},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none, // Allow shadows to overflow
      child: Row(
        children: List.generate(layers.length, (index) {
          final isActive = activeLayer == index;
          return Padding(
            padding: EdgeInsets.only(right: index < layers.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => onLayerChanged(index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: isActive
                      ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                      : ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF0EA5E9)
                          : const Color(0x331E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: isActive
                          ? null
                          : Border.all(
                              color: const Color(0x1AFFFFFF),
                              width: 1,
                            ),
                      boxShadow: isActive
                          ? [
                              const BoxShadow(
                                color: Color(0x660EA5E9),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          layers[index]['icon'] as IconData,
                          size: 18,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFFAFC2D3).withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          layers[index]['name'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
