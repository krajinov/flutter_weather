import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class UnitSelector extends StatelessWidget {
  final bool isCelsius;
  final ValueChanged<bool> onChanged;

  const UnitSelector({super.key, required this.isCelsius, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isCelsius ? AppColors.background : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  '°C',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isCelsius ? FontWeight.w600 : FontWeight.w500,
                    color: isCelsius
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !isCelsius ? AppColors.background : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  '°F',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: !isCelsius ? FontWeight.w600 : FontWeight.w500,
                    color: !isCelsius
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
