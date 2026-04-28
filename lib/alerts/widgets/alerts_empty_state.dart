import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_weather/l10n/generated/app_localizations.dart';

class AlertsEmptyState extends StatelessWidget {
  const AlertsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackground = isDark
        ? const Color(0xFF1F2F45)
        : const Color(0xFFFEF3C7);
    final textColor = isDark
        ? const Color(0xFFC4D5E4)
        : Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Center(
              child: Icon(LucideIcons.sun, size: 26, color: Color(0xFFFACC15)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noAlerts,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
