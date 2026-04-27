import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/alert_data.dart';

class AlertCard extends StatelessWidget {
  final AlertData alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _AlertCardColors.forAlert(alert, isDark: isDark);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colors.iconBgColor,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Center(
                        child: Icon(
                          alert.icon,
                          size: 18,
                          color: colors.iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alert.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                alert.time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.timeColor,
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
              color: colors.descriptionColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCardColors {
  final Color cardColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBgColor;
  final Color titleColor;
  final Color descriptionColor;
  final Color timeColor;
  final Color shadowColor;

  const _AlertCardColors({
    required this.cardColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBgColor,
    required this.titleColor,
    required this.descriptionColor,
    required this.timeColor,
    required this.shadowColor,
  });

  factory _AlertCardColors.forAlert(AlertData alert, {required bool isDark}) {
    if (isDark) {
      return _AlertCardColors(
        cardColor: alert.cardColor,
        borderColor: alert.borderColor,
        iconColor: alert.iconColor,
        iconBgColor: alert.iconBgColor,
        titleColor: AppColors.textPrimary,
        descriptionColor: const Color(0xFFC4D5E4),
        timeColor: alert.timeColor,
        shadowColor: const Color(0x4D000000),
      );
    }

    if (alert.isRainAlert) {
      return const _AlertCardColors(
        cardColor: Color(0xFFEFF6FF),
        borderColor: Color(0xFFBFDBFE),
        iconColor: Color(0xFF2563EB),
        iconBgColor: Color(0xFFDBEAFE),
        titleColor: Color(0xFF0F172A),
        descriptionColor: Color(0xFF475569),
        timeColor: Color(0xFF2563EB),
        shadowColor: Color(0x140F172A),
      );
    }

    if (alert.isSevereAlert) {
      return const _AlertCardColors(
        cardColor: Color(0xFFFFF1F2),
        borderColor: Color(0xFFFECACA),
        iconColor: Color(0xFFDC2626),
        iconBgColor: Color(0xFFFEE2E2),
        titleColor: Color(0xFF0F172A),
        descriptionColor: Color(0xFF475569),
        timeColor: Color(0xFFDC2626),
        shadowColor: Color(0x140F172A),
      );
    }

    return const _AlertCardColors(
      cardColor: Color(0xFFFFF7ED),
      borderColor: Color(0xFFFED7AA),
      iconColor: Color(0xFFEA580C),
      iconBgColor: Color(0xFFFFEDD5),
      titleColor: Color(0xFF0F172A),
      descriptionColor: Color(0xFF475569),
      timeColor: Color(0xFFEA580C),
      shadowColor: Color(0x140F172A),
    );
  }
}
