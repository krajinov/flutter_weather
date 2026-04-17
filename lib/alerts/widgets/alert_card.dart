import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/alert_data.dart';

class AlertCard extends StatelessWidget {
  final AlertData alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: alert.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: alert.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: alert.iconBgColor,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Center(
                      child: Icon(alert.icon, size: 18, color: alert.iconColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    alert.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                alert.time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: alert.timeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            alert.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFC4D5E4),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
