import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AlertsEmptyState extends StatelessWidget {
  const AlertsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2F45),
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Center(
              child: Icon(LucideIcons.sun, size: 26, color: Color(0xFFFACC15)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No alerts right now',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFC4D5E4),
            ),
          ),
        ],
      ),
    );
  }
}
